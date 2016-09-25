require "rails_helper"

describe Mail::Message do
  let(:personalization) { subject.send(:personalization) }
  let(:sg_mail) { subject.send(:sg_mail) }

  describe "#template_id" do
    it "sets tempalte id in sengrid mail object" do
      subject.set_template_id("X")
      expect(sg_mail.template_id).to eq("X")
    end
  end

  describe "#substitute" do
    before do
      @substitution = subject.substitute("%subject%", "Hi!")
    end

    it "creates substitution with valid data" do
      expect(@substitution.substitution).to eq("%subject%" => "Hi!")
    end

    it "adds substitution to personalization object" do
      expect(personalization.substitutions.size).to eq(1)
    end

    it "adds substitution to collection" do
      subject.substitute("%body%", "blah")
      expect(personalization.substitutions.size).to eq(2)
    end
  end

  describe "#sg_request_body" do
    it "adds sender with valid format" do
      subject.from = ["sender@platan.us"]
      expect(subject.sg_request_body).to eq("from" => { "email" => "sender@platan.us" })
    end

    it "adds recipients with valid format" do
      subject.to = ["recipient1@platan.us"]
      subject.cc = "recipient2@platan.us"
      subject.bcc = ["recipient3@platan.us", "recipient4@platan.us"]

      result = {
        "personalizations" => [
          {
            "to" => [{ "email" => "recipient1@platan.us" }],
            "cc" => [{ "email" => "recipient2@platan.us" }],
            "bcc" => [{ "email" => "recipient3@platan.us" }, { "email" => "recipient4@platan.us" }]
          }
        ]
      }

      expect(subject.sg_request_body).to eq(result)
    end

    it "adds template_id from hash params" do
      subject[:template_id] = "X"
      expect(subject.sg_request_body).to eq("template_id" => "X")
    end

    it "adds template_id from accessor" do
      subject.set_template_id("Y")
      expect(subject.sg_request_body).to eq("template_id" => "Y")
    end
  end
end
