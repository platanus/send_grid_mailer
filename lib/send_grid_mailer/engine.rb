module SendGridMailer
  class Engine < ::Rails::Engine
    isolate_namespace SendGridMailer

    config.generators do |g|
      g.test_framework :rspec, fixture: false
      g.fixture_replacement :factory_girl, dir: "spec/factories"
    end

    initializer "initialize" do
      require_relative "./errors"
      require_relative "./logger"
      require_relative "./api"
      require_relative "./interceptors_handler"
      require_relative "./interceptor/recipient_interceptor"
      require_relative "./definition"
      require_relative "./mailer_base_ext"
    end

    initializer "add_sendgrid_deliverer", before: "action_mailer.set_configs" do
      require_relative "./deliverer"
      ActionMailer::Base.add_delivery_method(:sendgrid, SendGridMailer::Deliverer)
    end
  end
end
