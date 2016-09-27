module ActionMailer
  class Base < AbstractController::Base
    SendGridMailer::Definition::METHODS.each do |method_name|
      define_method(method_name) do |*args|
        @_message.sg_definition.send(method_name, *args)
      end
    end

    def mail(headers = {}, &_block)
      return super if self.class.delivery_method != :sendgrid
      define_sg_mail(headers)
      m = @_message
      wrap_delivery_behavior!
      headers.each { |k, v| m[k] = v }
      @_mail_was_called = true
      m
    end

    private

    def define_sg_mail(data = {})
      set_sender(data[:from])
      set_recipients(:to, data[:to])
      set_recipients(:cc, data[:cc])
      set_recipients(:bcc, data[:bc])
      set_subject(data[:subject])
      set_body(data[:body], data[:content_type])
      set_template_id(data[:template_id])
    end
  end
end
