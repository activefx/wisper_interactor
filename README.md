# WisperInteractor

[![Gem Version](https://img.shields.io/gem/v/wisper_interactor.svg?style=flat)](https://rubygems.org/gems/wisper_interactor)
[![Build Status](https://secure.travis-ci.org/activefx/wisper_interactor.png)](http://travis-ci.org/activefx/wisper_interactor)
[![Code Climate](https://codeclimate.com/github/activefx/wisper_interactor/badges/gpa.svg)](https://codeclimate.com/github/activefx/wisper_interactor)
[![Dependency Status](https://gemnasium.com/activefx/wisper_interactor.png)](https://gemnasium.com/activefx/wisper_interactor)
[![Test Coverage](https://codeclimate.com/github/activefx/wisper_interactor/badges/coverage.svg)](https://codeclimate.com/github/activefx/wisper_interactor/coverage)

WisperInteractor extends [Interactor](https://github.com/collectiveidea/interactor) with PubSub capabilities using [Wisper](https://github.com/krisleech/wisper). Instead of including the Interactor module, your interactor classes should inherit from WisperInteractor::Base. All Interactor methods are available such as the before, after, and around hooks, the rollback method, and the interactor class is still intialized or called with the context options. 

As an interactor is designed to encapsulate your application's business logic and keep it out of your controllers, it makes sense to combine that functionality with Wisper's PubSub capabilities, further decoupling business logic from application code and external concerns. 

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'wisper_interactor'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install wisper_interactor

## Usage

````ruby 
class NewsletterSignup < WisperInteractor::Base 

  # Subscribe a class that listens to Wisper events. For example, 
  # if your NewletterSignup interactor is going to publish a 
  # :signup_successful event, your AddMailchimpSubscriber listener
  # should have a #signup_successful and possibly also a #signup_failed
  # method to handle to the corresponding events. See the Wisper 
  # documentation for futher information.  
  # 
  # .subscribe can be called multiple times in a WisperInteractor, and
  # can also accept options that are passed to the Wisper publisher. 
  # 
  subscribe AddMailchimpSubscriber
  subscribe NewsletterAnalyticsService, async: true

  # Runs after all other Interactor hooks when the interactor executes 
  # successfully. It is recommended that you broadcast a success 
  # message here that Wisper listeners can subscribe to in the future.
  # 
  on_success do
    broadcast(:newsletter_signup_succeeded, context.params)
  end

  # Runs in the event of any failure of the interactor. Keep in mind that
  # the interactor before hook, as well as the first portion of an 
  # around hook will have run in the event of a failure. It is recommended
  # that you broadcast a failure message here that Wisper listeners can 
  # subscribe to in the future.
  # 
  on_failure do
    broadcast(:newsletter_signup_failed, context.params)
  end

  # This is where you should place the core business logic of your 
  # interactor. This is evaulated in the context of the instance, 
  # and will have access to any instance methods you have defined 
  # as well as the interactor context method. You should use this
  # for your logic instead of #call as specified in the Interactor
  # documentation. 
  # 
  # If this block executes successfully, the on_success callback is
  # called, and if it fails or raises an error, the on_failure 
  # callback is executed. 
  # 
  perform do
    if form.validate(context.params)
      form.save
    else
      context.fail!(message: "Failed to create model.")
    end
  end

  # Example instance method
  # 
  def form
    context.form ||= NewsletterSignupForm.new
  end

  # As interactors can be chained together using an Interactor::Organizer, 
  # you may for example want to include logic to unsubscribe a user from 
  # your newsletter should a future interactor fail. This is of course 
  # completely optional. 
  # 
  def rollback
    # logic for undoing interactor action 
  end
end

# Example execution of the NewsletterSignup interactor
# 
NewsletterSignup.call(params: { email: 'info@example.com'})
````

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

1. Fork it ( https://github.com/[my-github-username]/wisper_interactor/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

