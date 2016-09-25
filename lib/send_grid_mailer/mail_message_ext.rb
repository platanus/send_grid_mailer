module Mail
  class Message
    SG_METHODS = [
      :substitute,
      :set_template_id
    ]

    def substitute(key, value)
      personalization.substitutions = SendGrid::Substitution.new(key: key, value: value)
    end

    def set_template_id(value)
      return unless value
      sg_mail.template_id = value
    end

    def sg_request_body
      set_sender
      set_recipients
      set_subject(param_value(:subject))
      set_template_id(param_value(:template_id))
      set_content(param_value(:content), "plain")
      set_content(param_value(:html_content), "html")
      add_attachments
      sg_mail.personalizations = personalization if personalization?
      sg_mail.to_json
    end

    private

    def set_sender
      sg_mail.from = SendGrid::Email.new(email: from.first) if from
    end

    def set_recipients
      to.each { |recipient| personalization.to = SendGrid::Email.new(email: recipient) } if to
      cc.each { |recipient| personalization.cc = SendGrid::Email.new(email: recipient) } if cc
      bcc.each { |recipient| personalization.bcc = SendGrid::Email.new(email: recipient) } if bcc
    end

    def set_subject(value)
      return unless value
      personalization.subject = value
    end

    def set_content(value, type)
      return unless value
      sg_mail.contents = SendGrid::Content.new(type: "text/#{type}", value: value)
    end

    def add_attachments
      attachments.each do |attachment|
        sg_mail.attachments = add_attachment(attachment)
      end
    end

    def add_attachment(file)
      attachment = SendGrid::Attachment.new
      attachment.content = Base64.strict_encode64(file.read)
      attachment.type = file.content_type.to_s.split(";").first
      attachment.filename = file.filename
      attachment.disposition = (file.content_disposition =~ /inline/) ? 'inline' : 'attachment'
      attachment.content_id = file.content_id
      attachment
    end

    def personalization
      @personalization ||= SendGrid::Personalization.new
    end

    def sg_mail
      @sg_mail ||= SendGrid::Mail.new
    end

    def personalization?
      !personalization.to_json.empty?
    end

    def param_value(key)
      self[key].try(:value)
    end
  end
end
