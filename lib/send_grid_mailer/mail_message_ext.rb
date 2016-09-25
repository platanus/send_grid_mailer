module Mail
  class Message
    attr_accessor :template_id

    def substitute(key, value)
      personalization.substitutions = SendGrid::Substitution.new(key: key, value: value)
    end

    private

    def personalization
      @personalization ||= SendGrid::Personalization.new
    end
  end
end
