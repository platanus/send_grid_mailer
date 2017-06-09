module SendGridMailer
  class Deliverer

    def deliver!(sg_definition)
      logger = SendGridMailer::Logger.new(sg_definition)
      logger.log_definition
      response = send_mail(sg_definition.to_json)
      logger.log_result(response)
      response
      nil
    end

    private

    def send_mail(sg_mail)
      sg_api.client.mail._('send').post(request_body: sg_mail)
    end

    def sg_api
      @sg_api ||= SendGrid::API.new(api_key: sg_api_key)
    end

    def sg_api_key
      get_api_key || raise(SendGridMailer::Exception.new("Missing sendgrid API key"))
    end

    def get_api_key
      Rails.application.config.action_mailer.sendgrid_settings[:api_key]
    rescue
      nil
    end
  end
end
