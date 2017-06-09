module SendGridMailer
  class Deliverer
    include InterceptorsHandler

    def deliver!(sg_definition)
      execute_interceptors(sg_definition)
      logger = SendGridMailer::Logger.new(sg_definition)
      logger.log_definition
      response = sg_api.send_mail(sg_definition)
      logger.log_result(response)
      response
      nil
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
