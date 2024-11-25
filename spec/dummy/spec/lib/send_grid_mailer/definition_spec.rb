require "rails_helper"

describe SendGridMailer::Definition do
  let(:definition) { described_class.new }
  let(:personalization) { definition.send(:personalization) }
  let(:mail) { definition.send(:mail) }

  describe "#template_id" do
    it "sets tempalte id in sengrid mail object" do
      definition.set_template_id("X")
      expect(mail.template_id).to eq("X")
    end
  end

  describe "#substitute" do
    let!(:substitution) { definition.substitute("%definition%", "Hi!") }

    it "creates substitution with valid data" do
      expect(substitution).to eq("%definition%" => "Hi!")
    end

    it "adds substitution to personalization object" do
      expect(personalization.substitutions.size).to eq(1)
    end

    it "adds substitution to collection" do
      definition.substitute("%body%", "blah")
      expect(personalization.substitutions.size).to eq(2)
    end
  end

  describe "#dynamic_template_data" do
    let!(:substitution) { definition.dynamic_template_data(key: 'value') }

    it "creates substitution with valid data" do
      expect(substitution).to eq(key: 'value')
    end

    it "adds substitution to personalization object" do
      expect(personalization.dynamic_template_data.size).to eq(1)
    end

    it "add dynamic_data to data hash" do
      definition.dynamic_template_data(other_key: 'other_value')
      expect(personalization.dynamic_template_data.size).to eq(2)
    end

    it "merges new keys into dynamic_data hash" do
      definition.dynamic_template_data(other_key: 'other_value')
      expect(personalization.dynamic_template_data).to eq(key: 'value', other_key: 'other_value')
    end
  end

  describe "#set_sender" do
    it "adds sender to mail object" do
      definition.set_sender("sender@platan.us")
      expect(mail.from).to eq("email" => "sender@platan.us")
    end
  end

  describe "#set_sender" do
    it "adds sender with format to mail object" do
      definition.set_sender("Sender Name <sender@platan.us>")
      expect(mail.from).to eq("email" => "sender@platan.us", "name" => "Sender Name")
    end
  end

  describe "#set_reply_to" do
    it "adds reply to to mail object" do
      definition.set_reply_to("Sender Name <reply_to@platan.us>")
      expect(mail.reply_to).to eq("email" => "reply_to@platan.us", "name" => "Sender Name")
    end
  end

  describe "#set_recipients" do
    let(:m1) { "leandro@platan.us" }
    let(:m2) { "ldlsegovia@gmail.com" }

    it "adds recipients using splat operator" do
      definition.set_recipients(:to, m1, m2)
      expect(personalization.tos).to eq([{ "email" => m1 }, { "email" => m2 }])
    end

    it "adds recipients passing emails array" do
      definition.set_recipients(:to, [m1, m2])
      expect(personalization.tos).to eq([{ "email" => m1 }, { "email" => m2 }])
    end

    it "adds bcc recipient" do
      definition.set_recipients(:bcc, m1)
      expect(personalization.bccs).to eq([{ "email" => m1 }])
    end

    it "adds cc recipient" do
      definition.set_recipients(:cc, m1)
      expect(personalization.ccs).to eq([{ "email" => m1 }])
    end
  end

  describe "#set_definition" do
    it "adds definition to personalization object" do
      definition.set_subject("Hi!")
      expect(personalization.subject).to eq("Hi!")
    end
  end

  describe "#set_content" do
    it "adds content to mail object" do
      definition.set_content("X")
      expect(mail.contents).to eq([{ "type" => "text/plain", "value" => "X" }])
    end

    it "adds content with different type" do
      definition.set_content("X", "other/type")
      expect(mail.contents).to eq([{ "type" => "other/type", "value" => "X" }])
    end
  end

  describe "#add_header" do
    it "adds headers to personalization object" do
      definition.add_header("HEADER1", "VALUE1")
      definition.add_header("HEADER2", "VALUE2")
      expect(personalization.headers).to eq("HEADER1" => "VALUE1", "HEADER2" => "VALUE2")
    end
  end

  describe "#add_category" do
    it "adds categories to mail object" do
      definition.add_category("category1")
      definition.add_category("category2")
      expect(mail.categories).to eq(["category1", "category2"])
    end
  end

  describe "#add_attachment" do
    it "adds file to mail object" do
      file = File.read(fixture_file_upload("spec/dummy/spec/assets/image.png"))
      definition.add_attachment(file, "platanus.png", "image/png")
      attachment = mail.attachments.first
      expect(attachment["type"]).to match("image/png")
      expect(attachment["disposition"]).to match("inline")
      expect(attachment["content"]).to eq(Base64.strict_encode64(file))
    end
  end
end
