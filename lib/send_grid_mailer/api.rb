module SendGridMailer
  class Api
    def initialize(api_key)
      @api_key = api_key || raise(SendGridMailer::Exception.new("Missing sendgrid API key"))
    end

    def send_mail(sg_definition)
      sg_api.client.mail._('send').post(request_body: sg_definition.to_json)
    end

    private

    def sg_api
      @sg_api ||= SendGrid::API.new(api_key: @api_key)
    end
  end
end
