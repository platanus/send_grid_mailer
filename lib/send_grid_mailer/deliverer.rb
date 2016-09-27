module SendGridMailer
  class Deliverer
    attr_accessor :settings

    def initialize(settings)
      self.settings = settings.merge(return_response: true)
    end

    def api_key
      settings[:api_key] || raise(SendGridMailer::Exception.new("missing sendgrid API key"))
    end

    def deliver!(msg)
      logger = SendGridMailer::Logger.new(msg.sg_definition)
      logger.log_definition
      response = sg_api.client.mail._('send').post(request_body: msg.sg_definition.to_json)
      logger.log_result(response)
    end

    private

    def sg_api
      @sg_api ||= SendGrid::API.new(api_key: api_key)
    end
  end
end
