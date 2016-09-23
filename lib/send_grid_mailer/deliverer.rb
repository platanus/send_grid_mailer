module SendGridMailer
  class Deliverer
    include SendGrid

    attr_accessor :settings

    def initialize(settings)
      self.settings = settings
    end

    def api_key
      settings[:api_key]
    end

    def deliver!(_mail)
      puts "TODO"
    end
  end
end
