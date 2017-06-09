module SendGridMailer
  class Deliverer
    attr_accessor :settings

    def initialize(settings)
      self.settings = settings.merge(return_response: true)
    end

    def api_key
      settings[:api_key] || raise(SendGridMailer::Exception.new("Missing sendgrid API key"))
    end

    def deliver!(msg)
      logger = SendGridMailer::Logger.new(msg.sg_definition)
      logger.log_definition
      response = send_mail(msg.sg_definition.to_json)
      logger.log_result(response)
      response
    end

    private

    def send_mail(sg_mail)
      sg_api.client.mail._('send').post(request_body: sg_mail)
    end

    def sg_api
      @sg_api ||= SendGrid::API.new(api_key: api_key)
    end
  end
end
