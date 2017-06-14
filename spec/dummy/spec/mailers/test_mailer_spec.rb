require "rails_helper"

describe TestMailer do
  def expect_valid_sg_api_request(request_body)
    expect_sg_api_request(SendGridMailer::Api::SUCCESS_CODE, request_body)
    deliver
  end

  def expect_invalid_sg_api_request(request_body, errors)
    error_code = "404"
    result = { errors: errors }.to_json
    expect_sg_api_request(error_code, request_body, result)
    expect { deliver }.to raise_error(SendGridMailer::ApiError, "sendgrid api error") do |e|
      expect(e.error_code).to eq(error_code)
      expect(e.errors).to eq(errors)
    end
  end

  def expect_sg_api_request(status_code, request_body, result = nil)
    result = double(status_code: status_code, body: result)
    client2 = double(post: result)
    client1 = double(_: client2)
    expect_any_instance_of(SendGrid::Client).to receive(:_).with(:mail).and_return(client1)
    expect(client2).to receive(:post).with(request_body: request_body).and_return(result)
  end

  before { allow(TestMailer).to receive(:delivery_method).and_return(:sendgrid) }

  context "with valid API key" do
    before { allow_any_instance_of(SendGridMailer::Deliverer).to receive(:api_key).and_return("X") }

    context "with unsuccessful response" do
      let(:deliver) { described_class.body_email.deliver_now! }

      it "sends mail with valid body" do
        request_body = {
          "from" =>
            {
              "email" => "default-sender@platan.us"
            },
          "personalizations" => [
            {
              "subject" => "Body email"
            }
          ],
          "content" => [
            {
              "type" => "text/plain",
              "value" => "Body"
            }
          ]
        }

        errors = [
          {
            'field' => 'from.email',
            'message' => 'The from email does not...'
          },
          {
            'field' => 'personalizations.0.to',
            'message' => 'The to array is required...'
          }
        ]

        expect_invalid_sg_api_request(request_body, errors)
      end
    end

    context "setting body" do
      let(:deliver) { described_class.body_email.deliver_now! }

      it "sends mail with valid body" do
        request_body = {
          "from" =>
            {
              "email" => "default-sender@platan.us"
            },
          "personalizations" => [
            {
              "subject" => "Body email"
            }
          ],
          "content" => [
            {
              "type" => "text/plain",
              "value" => "Body"
            }
          ]
        }

        expect_valid_sg_api_request(request_body)
      end
    end

    context "setting body from params" do
      let(:deliver) { described_class.body_params_email.deliver_now! }

      it "sends mail with valid body" do
        request_body = {
          "from" =>
            {
              "email" => "default-sender@platan.us"
            },
          "personalizations" => [
            {
              "subject" => "Body params email"
            }
          ],
          "content" => [
            {
              "type" => "text/html",
              "value" => "<h1>Body Params</h1>"
            }
          ]
        }

        expect_valid_sg_api_request(request_body)
      end
    end

    context "setting body from rails template" do
      let(:deliver) { described_class.rails_tpl_email.deliver_now! }

      it "sends mail with valid body" do
        request_body = {
          "from" =>
            {
              "email" => "default-sender@platan.us"
            },
          "personalizations" => [
            {
              "subject" => "Rails tpl email"
            }
          ],
          "content" => [
            {
              "type" => "text/html",
              "value" => "<html>\n  <body>\n    Rails Template!\n\n  </body>\n</html>\n"
            }
          ]
        }

        expect_valid_sg_api_request(request_body)
      end
    end

    context "overriding default from" do
      let(:request_body) do
        {
          "from" =>
            {
              "email" => "override@platan.us"
            },
          "personalizations" => [
            {
              "subject" => subject
            }
          ],
          "content" => [
            {
              "type" => "text/plain",
              "value" => "X"
            }
          ]
        }
      end

      context "using params" do
        let(:deliver) { described_class.from_params_email.deliver_now! }
        let(:subject) { "From params email" }

        it "sends mail with valid sender" do
          expect_valid_sg_api_request(request_body)
        end
      end

      context "using methods" do
        let(:deliver) { described_class.from_email.deliver_now! }
        let(:subject) { "From email" }

        it "sends mail with valid sender" do
          expect_valid_sg_api_request(request_body)
        end
      end
    end

    context "setting recipients" do
      let(:request_body) do
        {
          "from" =>
            {
              "email" => "default-sender@platan.us"
            },
          "personalizations" => [
            {
              "to" => [
                {
                  "email" => "r1@platan.us"
                },
                {
                  "email" => "r2@platan.us"
                }
              ],
              "cc" => [
                {
                  "email" => "r4@platan.us"
                }
              ],
              "bcc" => [
                {
                  "email" => "r5@platan.us"
                }
              ],
              "subject" => subject
            }
          ],
          "content" => [
            {
              "type" => "text/plain",
              "value" => "X"
            }
          ]
        }
      end

      context "using params" do
        let(:deliver) { described_class.recipients_params_email.deliver_now! }
        let(:subject) { "Recipients params email" }

        it "sends mail with valid recipients" do
          expect_valid_sg_api_request(request_body)
        end
      end

      context "using methods" do
        let(:deliver) { described_class.recipients_email.deliver_now! }
        let(:subject) { "Recipients email" }

        it "sends mail with valid recipients" do
          expect_valid_sg_api_request(request_body)
        end
      end
    end

    context "setting template id" do
      let(:request_body) do
        {
          "from" =>
            {
              "email" => "default-sender@platan.us"
            },
          "personalizations" => [
            {
              "subject" => subject
            }
          ],
          "template_id" => "XXX"
        }
      end

      context "using params" do
        let(:deliver) { described_class.template_id_params_email.deliver_now! }
        let(:subject) { "Template id params email" }

        it "sends mail with valid template" do
          expect_valid_sg_api_request(request_body)
        end
      end

      context "using methods" do
        let(:deliver) { described_class.template_id_email.deliver_now! }
        let(:subject) { "Template id email" }

        it "sends mail with valid template id" do
          expect_valid_sg_api_request(request_body)
        end
      end
    end

    context "setting subject" do
      let(:request_body) do
        {
          "from" =>
            {
              "email" => "default-sender@platan.us"
            },
          "personalizations" => [
            {
              "subject" => "My Subject"
            }
          ],
          "content" => [
            {
              "type" => "text/plain",
              "value" => "X"
            }
          ]
        }
      end

      context "using params" do
        let(:deliver) { described_class.subject_params_email.deliver_now! }

        it "sends mail with valid subject" do
          expect_valid_sg_api_request(request_body)
        end
      end

      context "using methods" do
        let(:deliver) { described_class.subject_email.deliver_now! }

        it "sends mail with valid subject" do
          expect_valid_sg_api_request(request_body)
        end
      end
    end

    context "setting headers" do
      let(:request_body) do
        {
          "from" =>
            {
              "email" => "default-sender@platan.us"
            },
          "personalizations" => [
            {
              "subject" => subject,
              "headers" =>
                {
                  "HEADER-1" => "VALUE-1",
                  "HEADER-2" => "VALUE-2"
                }
            }
          ],
          "content" => [
            {
              "type" => "text/plain",
              "value" => "X"
            }
          ]
        }
      end

      context "using params" do
        let(:deliver) { described_class.headers_params_email.deliver_now! }
        let(:subject) { "Headers params email" }

        it "sends mail with valid headers" do
          expect_valid_sg_api_request(request_body)
        end
      end

      context "using methods" do
        let(:deliver) { described_class.headers_email.deliver_now! }
        let(:subject) { "Headers email" }

        it "sends mail with valid headers" do
          expect_valid_sg_api_request(request_body)
        end
      end
    end

    context "adding attachments" do
      let(:deliver) { described_class.add_attachments_email.deliver_now! }

      it "sends mail with valid body" do
        expect_any_instance_of(SendGrid::Attachment).to receive(:content).and_return("X")
        expect_any_instance_of(SendGrid::Attachment).to receive(:content_id).and_return("A")

        request_body = {
          "from" =>
            {
              "email" => "default-sender@platan.us"
            },
          "personalizations" => [
            {
              "subject" => "Add attachments email"
            }
          ],
          "content" => [
            {
              "type" => "text/plain",
              "value" => "X"
            }
          ],
          "attachments" => [
            {
              "content" => "X",
              "type" => "image/png",
              "filename" => "nana.png",
              "disposition" => "attachment",
              "content_id" => "A"
            }
          ]
        }

        expect_valid_sg_api_request(request_body)
      end
    end

    context "adding substitutions" do
      let(:deliver) { described_class.substitutions_email.deliver_now! }

      it "sends mail with valid body" do
        request_body = {
          "from" =>
            {
              "email" => "default-sender@platan.us"
            },
          "personalizations" => [
            {
              "subject" => "Substitutions email",
              "substitutions" =>
                {
                  "%key1%" => "value1",
                  "%key2%" => "value2"
                }
            }
          ],
          "content" => [
            {
              "type" => "text/plain",
              "value" => "X"
            }
          ]
        }

        expect_valid_sg_api_request(request_body)
      end
    end

    context "working with recipient interceptor" do
      let(:interceptor) { double(:interceptor, class: "RecipientInterceptor") }
      let(:deliver) { described_class.recipients_email.deliver_now! }
      let(:request_body) do
        {
          "from" =>
            {
              "email" => "default-sender@platan.us"
            },
          "personalizations" => [
            {
              "to" => [
                { "email" => "interceptor1@platan.us" },
                { "email" => "interceptor2@platan.us" }
              ],
              "subject" => "[STAGING] Recipients email",
              "headers" =>
                {
                  "X-Intercepted-To" => "r1@platan.us, r2@platan.us",
                  "X-Intercepted-Cc" => "r4@platan.us",
                  "X-Intercepted-Bcc" => "r5@platan.us"
                }
            }
          ],
          "content" => [
            {
              "type" => "text/plain",
              "value" => "X"
            }
          ]
        }
      end

      before do
        allow(interceptor).to receive(:instance_variable_get)
          .with(:@recipients).and_return(["interceptor1@platan.us", "interceptor2@platan.us"])
        allow(interceptor).to receive(:instance_variable_get)
          .with(:@subject_prefix).and_return("[STAGING]")
        allow(Mail).to receive(:class_variable_get)
          .with(:@@delivery_interceptors).and_return([interceptor])
      end

      it "sends mail with valid recipients" do
        expect_valid_sg_api_request(request_body)
      end
    end
  end

  context "with invalid API key" do
    let(:deliver) { described_class.body_email.deliver_now! }

    before do
      allow_any_instance_of(SendGridMailer::Deliverer).to receive(:api_key).and_return(nil)
    end

    it { expect { deliver }.to raise_error(SendGridMailer::InvalidApiKey) }
  end
end
