module SendGridMailer
  class Api
    include Logger

    SUCCESS_CODE = 202

    def initialize(api_key)
      @api_key = api_key || raise(SendGridMailer::InvalidApiKey)
    end

    def send_mail(sg_definition)
      response = sg_api.client.mail._('send').post(request_body: sg_definition.to_json)
      handle_response(response)
    end

    private

    def handle_response(response)
      if response.status_code.to_i != SUCCESS_CODE
        errors = response_errors(response)
        log_api_error_response(response.status_code, errors)
        raise SendGridMailer::ApiError.new(response.status_code, errors)
      end

      log_api_success_response(response)
      response
    end

    def response_errors(response)
      JSON.parse(response.body)["errors"]
    end

    def sg_api
      @sg_api ||= SendGrid::API.new(api_key: @api_key)
    end
  end
end
