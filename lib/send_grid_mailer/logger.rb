module SendGridMailer
  module Logger
    def log_definition(definition)
      mail = definition.mail
      personalization = definition.personalization

      data = {
        "Subject" => personalization.subject,
        "Template ID" => mail.template_id,
        "From" => log_email(mail.from),
        "To" => log_emails(personalization, :tos),
        "Cc" => log_emails(personalization, :ccs),
        "Bcc" => log_emails(personalization, :bccs),
        "Substitutions" => log_pairs(personalization.substitutions),
        "Headers" => log_pairs(personalization.headers),
        "body" => log_contents(mail),
        "Attachments" => log_attachments(mail)
      }

      log(build_definition_message(data))
    end

    def log_api_success_response(response, api_call_type)
      log(success_message(response, api_call_type))
    end

    def log_api_error_response(status_code, errors, api_call_type)
      msg = failure_message(status_code, api_call_type)
      msg += log_errors(errors)
      log(msg)
    end

    private

    def success_message(response, api_call_type)
      case api_call_type
      when :mail
        "The E-mail was successfully sent :)\nStatus Code: #{response.status_code}"
      when :template
        "The template was succesfully fetched :)\nStatus Code: #{response.status_code}"
      end
    end

    def failure_message(status_code, api_call_type)
      case api_call_type
      when :mail
        "The E-mail was not sent :(\nStatus Code: #{status_code}\nErrors:"
      when :template
        "The template was not fetched :(\nStatus Code: #{status_code}\nErrors:"
      end
    end

    def log(msg)
      Rails.logger.info("\n#{msg}")
      nil
    end

    def build_definition_message(data)
      data = data.keys.map do |k|
        d = data[k].to_s
        "#{k}: #{(d.blank? ? '-' : d)}"
      end.join("\n")
    end

    def log_email(email)
      return if email.blank?
      email["email"]
    end

    def log_emails(personalization, origin)
      emails = personalization.send(origin)
      return if emails.blank?
      emails.map do |email|
        log_email(email)
      end.join(", ")
    end

    def log_attachments(mail)
      return if mail.attachments.blank?
      mail.attachments.map do |f|
        "\n\t#{f['filename']}"
      end.join("")
    end

    def log_contents(mail)
      return if mail.contents.blank?
      mail.contents.map do |content|
        "\n\ttype: #{content['type']}\n\tvalue: #{content['value']}"
      end.join("")
    end

    def log_pairs(hash)
      return if hash.blank?
      hash.keys.map do |k|
        "\n\t#{k} => #{hash[k]}"
      end.join("")
    end

    def log_errors(errors)
      errors.map do |error|
        msg = []
        msg << "#{error['field']}: " if error['field']
        msg << error['message']
        msg << " - help: #{error['help']}" if error['help']
        "\n\t* #{msg.join('')}"
      end.join("")
    end
  end
end
