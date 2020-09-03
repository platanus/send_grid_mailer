require "rails_helper"

describe SendGridMailer::Definition do
  let(:personalization) { subject.send(:personalization) }
  let(:mail) { subject.send(:mail) }

  describe "#template_id" do
    it "sets tempalte id in sengrid mail object" do
      subject.set_template_id("X")
      expect(mail.template_id).to eq("X")
    end
  end

  describe "#substitute" do
    before do
      @substitution = subject.substitute("%subject%", "Hi!")
    end

    it "creates substitution with valid data" do
      expect(@substitution).to eq("%subject%" => "Hi!")
    end

    it "adds substitution to personalization object" do
      expect(personalization.substitutions.size).to eq(1)
    end

    it "adds substitution to collection" do
      subject.substitute("%body%", "blah")
      expect(personalization.substitutions.size).to eq(2)
    end
  end

  describe "#set_sender" do
    it "adds sender to mail object" do
      subject.set_sender("sender@platan.us")
      expect(mail.from).to eq("email" => "sender@platan.us")
    end
  end

  describe "#set_sender" do
    it "adds sender with format to mail object" do
      subject.set_sender("Sender Name <sender@platan.us>")
      expect(mail.from).to eq("email" => "sender@platan.us", "name" => "Sender Name")
    end
  end

  describe "#set_recipients" do
    let(:m1) { "leandro@platan.us" }
    let(:m2) { "ldlsegovia@gmail.com" }

    it "adds recipients using splat operator" do
      subject.set_recipients(:to, m1, m2)
      expect(personalization.tos).to eq([{ "email" => m1 }, { "email" => m2 }])
    end

    it "adds recipients passing emails array" do
      subject.set_recipients(:to, [m1, m2])
      expect(personalization.tos).to eq([{ "email" => m1 }, { "email" => m2 }])
    end

    it "adds bcc recipient" do
      subject.set_recipients(:bcc, m1)
      expect(personalization.bccs).to eq([{ "email" => m1 }])
    end

    it "adds cc recipient" do
      subject.set_recipients(:cc, m1)
      expect(personalization.ccs).to eq([{ "email" => m1 }])
    end
  end

  describe "#set_subject" do
    it "adds subject to personalization object" do
      subject.set_subject("Hi!")
      expect(personalization.subject).to eq("Hi!")
    end
  end

  describe "#set_content" do
    it "adds content to mail object" do
      subject.set_content("X")
      expect(mail.contents).to eq([{ "type" => "text/plain", "value" => "X" }])
    end

    it "adds content with different type" do
      subject.set_content("X", "other/type")
      expect(mail.contents).to eq([{ "type" => "other/type", "value" => "X" }])
    end
  end

  describe "#add_header" do
    it "adds headers to personalization object" do
      subject.add_header("HEADER1", "VALUE1")
      subject.add_header("HEADER2", "VALUE2")
      expect(personalization.headers).to eq("HEADER1" => "VALUE1", "HEADER2" => "VALUE2")
    end
  end

  describe "#add_attachment" do
    it "adds file to mail object" do
      file = File.read(fixture_file_upload("image.png", "image/png"))
      subject.add_attachment(file, "platanus.png", "image/png")
      attachment = mail.attachments.first
      expect(attachment["type"]).to match("image/png")
      expect(attachment["disposition"]).to match("inline")
      expect(attachment["content"]).to eq(Base64.strict_encode64(file))
    end
  end
end
