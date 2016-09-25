module ActionMailer
  class Base < AbstractController::Base
    alias_method :old_mail, :mail

    Mail::Message::SG_METHODS.each do |method_name|
      define_method(method_name) do |*args|
        @_message.send(method_name, *args)
      end
    end

    def mail(headers = {}, &block)
      # Adding empty body with sendgrid delivery method to avoid template missing exception.
      headers[:body] = "" if self.class.delivery_method == :sendgrid
      old_mail(headers, &block)
    end
  end
end
