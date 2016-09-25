module ActionMailer
  class Base < AbstractController::Base
    Mail::Message::SG_METHODS.each do |method_name|
      define_method(method_name) do |*args|
        @_message.send(method_name, *args)
      end
    end
  end
end
