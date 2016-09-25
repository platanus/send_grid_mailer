module Mail
  class Message
    def substitute(key, value)
      personalization.substitutions = SendGrid::Substitution.new(key: key, value: value)
    end

    def set_template_id(value)
      sg_mail.template_id = value
    end

    def sg_request_body
      set_sender
      set_recipients
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

    def personalization
      @personalization ||= SendGrid::Personalization.new
    end

    def sg_mail
      @sg_mail ||= SendGrid::Mail.new
    end

    def personalization?
      !personalization.to_json.empty?
    end
  end
end
