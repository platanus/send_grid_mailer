module SendGridMailer
  class Definition
    METHODS = [
      :substitute,
      :dynamic_template_data,
      :set_template_id,
      :set_sender,
      :set_recipients,
      :set_reply_to,
      :set_subject,
      :set_content,
      :add_attachment,
      :add_header,
      :add_category
    ]

    def substitute(key, value, default = "")
      personalization.add_substitution(
        SendGrid::Substitution.new(key: key, value: value.to_s || default)
      )
    end

    def dynamic_template_data(object)
      personalization.add_dynamic_template_data(object)
    end

    def set_template_id(value)
      return unless value

      mail.template_id = value
    end

    def set_sender(email)
      email_info = extract_email_and_name(email)
      return unless email_info
    
      mail.from = SendGrid::Email.new(email: email_info[:email], name: email_info[:name])
    end

    def set_recipients(mode, *emails)
      emails.flatten.each do |email|
        next unless email

        personalization.send("add_#{mode}", SendGrid::Email.new(email: email))
      end
    end

    def set_reply_to(email)
      email_info = extract_email_and_name(email)
      return unless email_info
    
      mail.reply_to = SendGrid::Email.new(email: email_info[:email], name: email_info[:name])
    end

    def set_subject(value)
      return unless value

      personalization.subject = value
    end

    def set_content(value, type = nil)
      return unless value

      type ||= "text/plain"
      mail.add_content(SendGrid::Content.new(type: type, value: value))
    end

    def add_attachment(file, name, type, disposition = "inline", content_id = nil)
      attachment = SendGrid::Attachment.new
      attachment.content = Base64.strict_encode64(file)
      attachment.type = type
      attachment.filename = name
      attachment.disposition = disposition
      attachment.content_id = content_id
      mail.add_attachment(attachment)
    end

    def add_header(key, value)
      return if !key || !value

      personalization.add_header(SendGrid::Header.new(key: key, value: value))
    end

    def add_category(value)
      return unless value

      mail.add_category(SendGrid::Category.new(name: value))
    end

    def to_json
      mail.add_personalization(personalization) if personalization?
      mail.to_json
    end

    def mail
      @mail ||= SendGrid::Mail.new
    end

    def extract_email_and_name(email)
      return unless email
    
      matched_format = email.match(/<(.+)>/)
      if matched_format
        address = matched_format[1]
        name = email.match(/\"?([^<^\"]*)\"?\s?/)[1].strip
        { email: address, name: name }
      else
        { email: email }
      end
    end

    def clean_recipients(mode)
      personalization.instance_variable_set("@#{mode}s", [])
    end

    def personalization
      @personalization ||= SendGrid::Personalization.new
    end

    def personalization?; !personalization.to_json.empty? end

    def content?; mail.contents.present? end

    def sender?; mail.from.present? end

    def reply_to?; mail.reply_to.present? end

    def subject?; personalization.subject.present? end

    def template_id?; mail.template_id.present? end
  end
end
