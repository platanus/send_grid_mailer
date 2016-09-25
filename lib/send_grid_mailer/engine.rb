require_relative "./deliverer"
require_relative "./mail_message_ext"

module SendGridMailer
  class Engine < ::Rails::Engine
    isolate_namespace SendGridMailer

    config.generators do |g|
      g.test_framework :rspec, fixture: false
      g.fixture_replacement :factory_girl, dir: "spec/factories"
    end

    initializer "add_sendgrid_deliverer", before: "action_mailer.set_configs" do
      ActionMailer::Base.add_delivery_method(:sendgrid, SendGridMailer::Deliverer)
    end
  end
end
