module SendGridMailer
  class Api
    include Logger

    def initialize(api_key)
      @api_key = api_key || raise(SendGridMailer::InvalidApiKey)
    end

    def send_mail(sg_definition)
      response = sg_api.client.mail._('send').post(request_body: sg_definition.to_json)
      handle_response(response, :mail)
    end

    def get_template(sg_definition)
      response = sg_api.client.templates._(sg_definition.mail.template_id).get()
      handle_response(response, :template)
    end

    private

    def handle_response(response, api_call_type)
      status_code = response.status_code.to_i
      if status_code.between?(400, 600)
        errors = response_errors(response)
        log_api_error_response(status_code, errors, api_call_type)
        raise SendGridMailer::ApiError.new(status_code, errors)
      end

      log_api_success_response(response, api_call_type)
      response
    end

    def response_errors(response)
      body = JSON.parse(response.body)
      body["errors"] || [{ "message" => body["error"] }]
    end

    def sg_api
      @sg_api ||= SendGrid::API.new(api_key: @api_key)
    end
  end
end
