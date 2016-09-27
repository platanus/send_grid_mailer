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
      add_attachments
      add_headers(data.fetch(:headers, {}))
    end

    def add_attachments
      attachments.each do |attachment|
        add_attachment(
          attachment.read,
          attachment.filename,
          attachment.content_type.to_s.split(";").first,
          ((attachment.content_disposition =~ /inline/) ? 'inline' : 'attachment'),
          attachment.content_id
        )
      end
    end

    def add_headers(heads = {})
      heads.keys.each { |key| add_header(key, heads[key]) }
      @_message.header.fields.each { |field| add_header(field.name, field.value) }
    end
  end
end
