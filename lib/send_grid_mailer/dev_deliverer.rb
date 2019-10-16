module SendGridMailer
  class DevDeliverer
    include InterceptorsHandler
    include Logger
    require "letter_opener"

    def deliver!(sg_definition)
      @sg_definition = sg_definition
      execute_interceptors(@sg_definition)
      log_definition(@sg_definition)
      letter_opener_delivery_method.deliver!(mail)
    end

    private

    def sg_api
      @sg_api ||= Api.new(api_key)
    end

    def api_key
      Rails.application.config.action_mailer.sendgrid_dev_settings[:api_key]
    rescue
      nil
    end

    def letter_opener_delivery_method
      @letter_opener_delivery_method ||= LetterOpener::DeliveryMethod.new(location: '/tmp/mails')
    end

    def parsed_template
      template_response = sg_api.get_template(@sg_definition)
      template_versions = JSON.parse(template_response.body)["versions"]
      return unless template_versions.present?

      template_active_version = template_versions.find { |version| version["active"] == 1 }
      template_content = template_active_version["html_content"]
      @sg_definition.personalization.substitutions.each { |k, v| template_content.gsub!(k, v) }
      template_content
    end

    def emails(origin)
      @emails ||= {}
      return @emails[origin] if @emails.has_key?(origin)

      @emails[origin] = @sg_definition.personalization.send(origin)&.map {|em| em["email"]}
    end

    def mail
      template = (parsed_template || @sg_definition.mail.contents[0]['value']).html_safe
      m = Mail.new
      m.html_part = template
      m.subject = @sg_definition.personalization.subject
      m.from = @sg_definition.mail.from["email"] if @sg_definition.mail.from.present?
      m.to = emails(:tos) if emails(:tos).present?
      m.cc = emails(:ccs) if emails(:ccs).present?
      m.bcc = emails(:bccs) if emails(:bccs).present?

      m
    end
  end
end
