$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem"s version:
require "send_grid_mailer/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name          = "send_grid_mailer"
  s.version       = SendGridMailer::VERSION
  s.authors       = ["Platanus", "Leandro Segovia"]
  s.email         = ["rubygems@platan.us", "ldlsegovia@gmail.com"]
  s.homepage      = "https://github.com/platanus/send_grid_mailer"
  s.summary       = "Action Mailer adapter for using SendGrid"
  s.description   = "Is an Action Mailer adapter for using SendGrid in a Rails application"
  s.license       = "MIT"

  s.files = `git ls-files`.split($/).reject { |fn| fn.start_with? "spec" }
  s.bindir = "exe"
  s.executables = s.files.grep(%r{^exe/}) { |f| File.basename(f) }
  s.test_files = Dir["spec/**/*"]

  s.add_dependency "rails", "~> 4.2", ">= 4.2.0"
  s.add_dependency "sendgrid-ruby", "~> 4.0", ">= 4.0.4"
  s.add_development_dependency "pry"
  s.add_development_dependency "pry-rails"
  s.add_development_dependency "sqlite3"
  s.add_development_dependency "rspec-rails", "~> 3.4.0"
  s.add_development_dependency "guard-rspec", "~> 4.7"
  s.add_development_dependency "factory_girl_rails", "~> 4.6.0"
  s.add_development_dependency "coveralls"
end
