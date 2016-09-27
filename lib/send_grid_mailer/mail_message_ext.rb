module Mail
  class Message
    def sg_definition
      @sg_definition ||= SendGridMailer::Definition.new
    end
  end
end
