module SendGridMailer
  class DevDeliverer
    include InterceptorsHandler
    include Logger
    require "letter_opener"

    def deliver!(sg_definition)
      execute_interceptors(sg_definition)
      log_definition(sg_definition)
      mail = Mail.new do |m|
        m.html_part = parsed_template(sg_definition).html_safe
      end
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

    def parsed_template(sg_definition)
      template_response = sg_api.get_template(sg_definition)
      template_active_version = JSON.parse(template_response.body)["versions"].find do |version|
        version["active"] == 1
      end
      template_content = template_active_version["html_content"]
      sg_definition.personalization.substitutions.each { |k, v| template_content.gsub!(k, v) }
      template_content
    end
  end
end
