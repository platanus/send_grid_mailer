module SendGridMailer
  class Error < RuntimeError
  end

  class InvalidApiKey < Error
    def initialize
      super("The SendGrid API key is invalid or missing")
    end
  end

  class ApiError < Error
    attr_reader :error_code, :errors

    def initialize(error_code, errors)
      @error_code = error_code
      @errors = errors
      error_message = errors.map { |err| err['message'] }.join('. ')
      super("Sendgrid API error. Code: #{error_code}. Errors: #{error_message}")
    end
  end
end
