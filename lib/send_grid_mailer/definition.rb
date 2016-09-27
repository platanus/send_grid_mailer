module SendGridMailer
  class Definition
    METHODS = [
      :substitute,
      :set_template_id,
      :set_template_name,
      :set_sender,
      :set_recipients,
      :set_subject,
      :set_content,
      :add_attachment,
      :add_header,
      :content?
    ]

    attr_accessor :template_name

    def substitute(key, value, default = "")
      personalization.substitutions = SendGrid::Substitution.new(
        key: key, value: value.to_s || default)
    end

    def set_template_id(value)
      return unless value
      mail.template_id = value
    end

    def set_template_name(value)
      return unless value
      self.template_name = value
    end

    def set_sender(email)
      return unless email
      mail.from = SendGrid::Email.new(email: email)
    end

    def set_recipients(mode, *emails)
      emails.flatten.each do |email|
        next unless email
        personalization.send("#{mode}=", SendGrid::Email.new(email: email))
      end
    end

    def set_subject(value)
      return unless value
      personalization.subject = value
    end

    def set_content(value, type = nil)
      return unless value
      type = "text/plain" unless type
      mail.contents = SendGrid::Content.new(type: type, value: value)
    end

    def add_attachment(file, name, type, disposition = "inline", content_id = nil)
      attachment = SendGrid::Attachment.new
      attachment.content = Base64.strict_encode64(file)
      attachment.type = type
      attachment.filename = name
      attachment.disposition = disposition
      attachment.content_id = content_id
      mail.attachments = attachment
    end

    def add_header(key, value)
      return if !key || !value
      personalization.headers = SendGrid::Header.new(key: key, value: value)
    end

    def to_json
      mail.personalizations = personalization if personalization?
      mail.to_json
    end

    def mail
      @mail ||= SendGrid::Mail.new
    end

    def personalization
      @personalization ||= SendGrid::Personalization.new
    end

    def personalization?
      !personalization.to_json.empty?
    end

    def content?
      !mail.contents.blank?
    end

    def template_id?
      !mail.template_id.blank?
    end

    def template_name?
      !template_name.blank?
    end
  end
end
