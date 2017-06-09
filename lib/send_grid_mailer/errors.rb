module SendGridMailer
  class Error < RuntimeError
  end

  class InvalidApiKey < Error
    def initialize
      super("the SendGrid API key is invalid or missing")
    end
  end

  class ApiError < Error
    attr_reader :error_code, :errors

    def initialize(error_code, errors)
      @error_code = error_code
      @errors = errors
      super("sendgrid api error")
    end
  end
end
