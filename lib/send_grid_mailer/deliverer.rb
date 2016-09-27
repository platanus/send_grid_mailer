module SendGridMailer
  class Deliverer
    attr_accessor :settings

    def initialize(settings)
      self.settings = settings
    end

    def api_key
      settings[:api_key] || raise(SendGridMailer::Exception.new("missing sendgrid API key"))
    end

    def deliver!(msg)
      msg.sg_definition.log
      response = sg_api.client.mail._('send').post(request_body: msg.sg_definition.to_json)
      Rails.logger.info "Status code: " + response.status_code.to_s
      response
    end

    private

    def sg_api
      @sg_api ||= SendGrid::API.new(api_key: api_key)
    end
  end
end
