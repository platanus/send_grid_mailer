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
      set_template_id_from_name(msg.sg_definition)
      logger = SendGridMailer::Logger.new(msg.sg_definition)
      logger.log_definition
      response = sg_api.client.mail._('send').post(request_body: msg.sg_definition.to_json)
      logger.log_result(response)
    end

    private

    def set_template_id_from_name(definition)
      return unless definition.template_name
      response = sg_api.client.templates.get

      if response.status_code != "200"
        raise(SendGridMailer::Exception.new(
                "Error trying to get templates. Status Code: #{response.status_code}"))
      end

      JSON.parse(response.body)["templates"].each do |tpl|
        definition.set_template_id(tpl["id"]) if tpl["name"] == definition.template_name
      end

      if !definition.template_id?
        raise(SendGridMailer::Exception.new(
                "No template with name #{definition.template_name}"))
      end
    end

    def sg_api
      @sg_api ||= SendGrid::API.new(api_key: api_key)
    end
  end
end
