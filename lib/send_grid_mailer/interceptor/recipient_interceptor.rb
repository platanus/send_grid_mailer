module SendGridMailer
  module Interceptor
    module RecipientInterceptor
      def self.perform(sg_definition, interceptor)
        add_custom_headers(sg_definition)
        add_recipients(sg_definition, interceptor)
        add_subject_prefix(sg_definition, interceptor)
      end

      def self.exec_recipients_interceptor(sg_definition, interceptor)
        add_custom_headers(sg_definition)
        add_recipients(sg_definition, interceptor)
        add_subject_prefix(sg_definition, interceptor)
      end

      def self.add_subject_prefix(sg_definition, interceptor)
        subject_prefix = interceptor.instance_variable_get(:@subject_prefix)
        subject = [subject_prefix, sg_definition.personalization.subject].join(" ").strip
        sg_definition.set_subject(subject)
      end

      def self.add_recipients(sg_definition, interceptor)
        recipients = interceptor.instance_variable_get(:@recipients)
        sg_definition.clean_recipients(:to)
        sg_definition.clean_recipients(:cc)
        sg_definition.clean_recipients(:bcc)
        sg_definition.set_recipients(:to, recipients)
      end

      def self.add_custom_headers(sg_definition)
        {
          'X-Intercepted-To' => sg_definition.personalization.tos || [],
          'X-Intercepted-Cc' => sg_definition.personalization.ccs || [],
          'X-Intercepted-Bcc' => sg_definition.personalization.bccs || []
        }.each do |header, addresses|
          addresses_str = addresses.map { |a| a["email"] }.join(", ")
          sg_definition.add_header(header, addresses_str)
        end
      end
    end
  end
end
