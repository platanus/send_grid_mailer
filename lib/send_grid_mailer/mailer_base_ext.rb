module ActionMailer
  class Base < AbstractController::Base
    alias_method :old_mail, :mail

    SendGridMailer::Definition::METHODS.each do |method_name|
      define_method(method_name) do |*args|
        sg_definition.send(method_name, *args)
      end
    end

    def mail(headers = {}, &_block)
      return old_mail(headers, &_block) if self.class.delivery_method != :sendgrid
      m = @_message

      # Call all the procs (if any)
      default_values = {}
      self.class.default.each do |k, v|
        default_values[k] = v.is_a?(Proc) ? instance_eval(&v) : v
      end

      # Handle defaults
      headers = headers.reverse_merge(default_values)
      headers[:subject] ||= default_i18n_subject

      define_sg_mail(headers)

      wrap_delivery_behavior!
      @_mail_was_called = true
      m
    end

    private

    def define_sg_mail(params = {})
      set_sender(params[:from]) unless sender?
      set_recipients(:to, params[:to])
      set_recipients(:cc, params[:cc])
      set_recipients(:bcc, params[:bcc])
      set_subject(params[:subject]) unless subject?
      set_body(params)
      add_attachments
      add_headers(params.fetch(:headers, {}))
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

    def set_body(params)
      return if sg_definition.template_name?
      set_template_id(params[:template_id])
      return if sg_definition.template_id?
      set_content(params[:body], params[:content_type])
      return if sg_definition.content?
      set_body_from_tpl(params)
    end

    def set_body_from_tpl(params)
      templates_path = params.delete(:template_path) || self.class.mailer_name
      templates_name = params.delete(:template_name) || action_name

      paths = Array(templates_path)
      template = lookup_context.find_all(templates_name, paths).first

      raise ActionView::MissingTemplate.new(
        paths, templates_name, paths, false, 'mailer') unless template

      set_content(render(template: template), template.type.to_s)
    end

    def sg_definition
      @_message.sg_definition
    end
  end
end
