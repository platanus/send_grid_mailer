module SendGridMailer
  class DevDeliverer
    include InterceptorsHandler
    include Logger

    def deliver!(sg_definition)
      execute_interceptors(sg_definition)
      response = sg_api.get_template(sg_definition)
      template_active_version = JSON.parse(response.body)["versions"].find do |version|
        version["active"] == 1
      end
      template_content = template_active_version["html_content"]
      log_template(template_content)
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
  end
end
