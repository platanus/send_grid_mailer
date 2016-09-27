module SendGridMailer
  class Logger
    attr_reader :definition

    def initialize(definition)
      @definition = definition
    end

    # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    def log_definition
      data = {
        "Subject" => personalization.subject,
        "Template ID" => mail.template_id,
        "From" => log_email(mail.from),
        "To" => log_emails(:tos),
        "Cc" => log_emails(:ccs),
        "Bcc" => log_emails(:bccs),
        "Substitutions" => log_pairs(personalization.substitutions),
        "Headers" => log_pairs(personalization.headers),
        "body" => log_contents,
        "Attachments" => log_attachments
      }

      data = data.keys.map do |k|
        d = data[k].to_s
        "#{k.light_blue}: #{(d.blank? ? '-' : d).light_yellow}"
      end.join("\n")

      Rails.logger.info("\n#{data}")
    end
    # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

    def log_result(response)
      msg = "The E-mail was successfully sent :)\nStatus Code: #{response.status_code}".green

      if response.status_code != "202"
        msg = "The E-mail was not sent :(\nStatus Code: #{response.status_code}\nErrors:"
        msg += log_errors(response.body)
        msg = msg.red
      end

      Rails.logger.info("\n#{msg}")
      nil
    end

    private

    def log_email(email)
      email["email"]
    end

    def log_emails(origin)
      emails = personalization.send(origin)
      return if emails.blank?
      emails.map do |email|
        log_email(email)
      end.join(", ")
    end

    def log_attachments
      return if mail.attachments.blank?
      mail.attachments.map do |f|
        "\n\t#{f['filename']}"
      end.join("")
    end

    def log_contents
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

    def mail
      definition.mail
    end

    def log_errors(body)
      JSON.parse(body)["errors"].map do |error|
        msg = []
        msg << "#{error['field']}: " if error['field']
        msg << error['message']
        msg << " - help: #{error['help']}" if error['help']
        "\n\t* #{msg.join('')}"
      end.join("")
    end

    def personalization
      definition.personalization
    end
  end
end
