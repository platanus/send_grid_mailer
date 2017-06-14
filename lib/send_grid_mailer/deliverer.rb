module SendGridMailer
  class Deliverer
    include InterceptorsHandler
    include Logger

    def deliver!(sg_definition)
      execute_interceptors(sg_definition)
      log_definition(sg_definition)
      sg_api.send_mail(sg_definition)
    end

    private

    def sg_api
      @sg_api ||= Api.new(api_key)
    end

    def api_key
      Rails.application.config.action_mailer.sendgrid_settings[:api_key]
    rescue
      nil
    end
  end
end
