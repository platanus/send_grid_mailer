class TestMailer < ApplicationMailer
  default from: "default-sender@platan.us"

  def body_email
    set_content("Body")
    mail
  end

  def body_params_email
    mail(body: "<h1>Body Params</h1>", content_type: "text/html")
  end

  def rails_tpl_email
    mail
  end

  def from_email
    set_sender("override@platan.us")
    mail(body: "X")
  end

  def from_params_email
    mail(from: "override@platan.us", body: "X")
  end

  def recipients_email
    set_recipients(:to, "r1@platan.us", "r2@platan.us")
    set_recipients(:cc, ["r4@platan.us"])
    set_recipients(:bcc, "r5@platan.us")
    mail(body: "X")
  end

  def recipients_params_email
    mail(
      body: "X",
      to: ["r1@platan.us", "r2@platan.us"],
      cc: ["r4@platan.us"],
      bcc: "r5@platan.us"
    )
  end

  def template_id_email
    set_template_id("XXX")
    mail
  end

  def template_id_params_email
    mail(template_id: "XXX")
  end

  def subject_email
    set_subject("My Subject")
    mail(body: "X")
  end

  def subject_params_email
    mail(subject: "My Subject", body: "X")
  end

  def headers_email
    headers["HEADER-1"] = "VALUE-1"
    headers["HEADER-2"] = "VALUE-2"
    mail(body: "X")
  end

  def headers_params_email
    mail(body: "X", headers: { "HEADER-1" => "VALUE-1", "HEADER-2" => "VALUE-2" })
  end

  def add_attachments_email
    image_path = File.expand_path("../../../spec/assets/image.png", __FILE__)
    attachments["nana.png"] = File.read(image_path)
    mail(body: "X")
  end

  def substitutions_email
    substitute "%key1%", "value1"
    substitute "%key2%", "value2"
    mail(body: "X")
  end

  def template_with_substitutions_email(value)
    set_template_id("XXX")
    substitute "%key%", value
    mail(to: "r1@platan.us", body: "X")
  end

  def dynamic_template_email(value)
    set_template_id("XXX")
    dynamic_template_data(key: value)
    mail(to: "r1@platan.us")
  end
end
