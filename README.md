# SendGrid Mailer
[![Gem Version](https://badge.fury.io/rb/send_grid_mailer.svg)](https://badge.fury.io/rb/send_grid_mailer)
[![Build Status](https://travis-ci.org/platanus/send_grid_mailer.svg?branch=master)](https://travis-ci.org/platanus/send_grid_mailer)
[![Coverage Status](https://coveralls.io/repos/github/platanus/send_grid_mailer/badge.svg)](https://coveralls.io/github/platanus/send_grid_mailer)

Is an Action Mailer adapter for using SendGrid in a Rails application and
It's built on top of the [sengrid-ruby](https://github.com/sendgrid/sendgrid-ruby) gem.

## Installation

Add to your Gemfile:

```ruby
gem "send_grid_mailer"
```

```bash
bundle install
```

We provide two delivery methods. For development environments, where sending the email is not required, you can use `:sendgrid_dev` to open it in the browser:

```ruby
config.action_mailer.delivery_method = :sendgrid_dev
config.action_mailer.sendgrid_dev_settings = {
  api_key: "YOUR-SENDGRID-API-KEY"
}
```

Otherwise, you can use `:sendgrid` to actually send the email:

```ruby
config.action_mailer.delivery_method = :sendgrid
config.action_mailer.sendgrid_settings = {
  api_key: "YOUR-SENDGRID-API-KEY"
}
```


## Usage

With this adapter you will be able to:

#### Set E-mail's Subject

```ruby
class TestMailer < ApplicationMailer
  def my_email
    set_subject("My Subject")
    mail
  end

  def my_email # through mail method's params
    mail(subject: "My Subject")
  end
end
```

#### Set E-mail's Body

```ruby
class TestMailer < ApplicationMailer
  def my_email
    set_content("Body")
    mail
  end

  def my_email # through mail method's params
    mail(body: "<h1>Body</h1>", content_type: "text/html")
  end
end
```

#### Set E-mail's Sender

```ruby
class TestMailer < ApplicationMailer
  default from: "default-sender@platan.us"

  def my_email
    set_sender("override-default-sender@platan.us")
    mail
  end

  def my_email # through mail method's params
    mail(from: "override@platan.us", body: "Body")
  end
end
```

#### Set E-mail's Recipients

```ruby
class TestMailer < ApplicationMailer
  def my_email
    set_recipients(:to, "r1@platan.us", "r2@platan.us")
    set_recipients(:cc, ["r4@platan.us"])
    set_recipients(:bcc, "r5@platan.us")
    mail
  end

  def my_email # through mail method's params
    mail(
      to: ["r1@platan.us", "r2@platan.us"],
      cc: ["r4@platan.us"],
      bcc: "r5@platan.us"
    )
  end
end
```

#### Set E-mail's Headers

```ruby
class TestMailer < ApplicationMailer
  def my_email
    headers["HEADER-1"] = "VALUE-1"
    headers["HEADER-2"] = "VALUE-2"
    mail
  end

  def my_email # through mail method's params
    mail(headers: { "HEADER-1" => "VALUE-1", "HEADER-2" => "VALUE-2" })
  end
end
```

#### Set E-mail's Attachments

```ruby
class TestMailer < ApplicationMailer
  def my_email # using Action Mailer method
    attachments["platanus.png"] = File.read("file-path")
    mail
  end

  def my_email # using this gem method
    file = File.read("file-path")
    add_attachment(file, "platanus.png", "image/png", "inline")
    mail
  end
end
```

#### Set SendGrid's Template

```ruby
class TestMailer < ApplicationMailer
  def my_email
    set_template_id("XXX")
    mail
  end

  def my_email # through mail method's params
    mail(template_id: "XXX")
  end
end
```

#### Add Substitutions in SendGrid's Template

```ruby
class TestMailer < ApplicationMailer
  def my_email
    substitute "%key1%", "value1"
    substitute "%key2%", "value2"
    mail
  end
end
```

> Remember: you need to specify al least: `body`, `template_id` or a Rails template.

## Recipient Interceptor

This gem is compatible with [Recipient Interceptor gem](https://github.com/croaky/recipient_interceptor/tree/v0.1.2).
However, this gem only uses its configuration. Internally, we modify the behaviour to play nice with [sengrid-ruby](https://github.com/sendgrid/sendgrid-ruby) gem.
So, the current code is based on [Recipient Interceptor v0.1.2](https://github.com/croaky/recipient_interceptor/tree/v0.1.2). New versions may not work.

To make it work...

Add to your Gemfile:

```ruby
gem "send_grid_mailer"
gem "recipient_interceptor"
```

In, for example, your `/my-project/config/environments/development.rb` file:

```ruby
Mail.register_interceptor RecipientInterceptor.new(
  ENV["EMAIL_RECIPIENTS"],
  subject_prefix: '[STAGING]'
)
```

## Testing

To run the specs you need to execute, **in the root path of the gem**, the following command:

```bash
bundle exec guard
```

You need to put **all your tests** in the `/send_grid_mailer/spec/dummy/spec/` directory.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## Credits

Thank you [contributors](https://github.com/platanus/send_grid_mailer/graphs/contributors)!

<img src="http://platan.us/gravatar_with_text.png" alt="Platanus" width="250"/>

SendGrid Mailer is maintained by [platanus](http://platan.us).

## License

SendGrid Mailer is © 2016 platanus, spa. It is free software and may be redistributed under the terms specified in the LICENSE file.
