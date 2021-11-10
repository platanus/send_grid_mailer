# Change Log
All notable changes to this project will be documented in this file.
This project adheres to [Semantic Versioning](http://semver.org/).

### v2.0.1

##### Fixed

* :sendgrid_dev delivery method doesn't work with rails templates and missing api key.

### v2.0.0

##### Changed

* Replace travis with circleci.

##### Removed

* Support for Ruby 2.5

### v1.2.1

##### Fixed

* :sendgrid_dev delivery method now works with Rails templates.

### v1.2.0

##### Added

* Add :sendgrid_dev delivery method

### v1.1.0

##### Added

* Detailed API errors

### v1.0.0

##### Added

* Implement "a version" of Recipients Interceptor https://github.com/croaky/recipient_interceptor compatible with SendGrid.
* Raise exceptions when api fails.

##### Removed

* Remove ability to set templates by name

### v0.5.0

##### Changed

* Support sender with standard email string "email> name", #3, thanks @agustinf

### v0.4.0

##### Changed

* Change Rails version to be "optimistic" in order to use the gem with Rails 5 too.

### v0.3.0

##### Added

* Add Hound configuration.
* Deploy with Travis CI.
* Configure coveralls.

### v0.2.0

##### Changed

* Removes useless colorize gem.

### v0.1.1

##### Fixed

* Logger fails with empty sender.

### v0.1.0

* Initial release.
