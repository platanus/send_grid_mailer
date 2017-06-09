module SendGridMailer
  module InterceptorsHandler
    def execute_interceptors(sg_definition)
      registered_interceptors.each do |interceptor|
        interceptor_class = "SendGridMailer::Interceptor::#{interceptor.class}".constantize
        interceptor_class.perform(sg_definition, interceptor)
      end
    end

    def registered_interceptors
      ::Mail.class_variable_get(:@@delivery_interceptors)
    end
  end
end
