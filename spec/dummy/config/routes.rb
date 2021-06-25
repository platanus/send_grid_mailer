Rails.application.routes.draw do
  mount SendGridMailer::Engine => "/send_grid_mailer"
end
