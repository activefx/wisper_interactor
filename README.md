# WisperInteractor

[![Gem Version](https://img.shields.io/gem/v/wisper_interactor.svg?style=flat)](https://rubygems.org/gems/wisper_interactor)
[![Build Status](https://secure.travis-ci.org/activefx/wisper_interactor.png)](http://travis-ci.org/activefx/wisper_interactor)
[![Code Climate](https://codeclimate.com/github/activefx/wisper_interactor/badges/gpa.svg)](https://codeclimate.com/github/activefx/wisper_interactor)
[![Dependency Status](https://gemnasium.com/activefx/wisper_interactor.png)](https://gemnasium.com/activefx/wisper_interactor)
[![Test Coverage](https://codeclimate.com/github/activefx/wisper_interactor/badges/coverage.svg)](https://codeclimate.com/github/activefx/wisper_interactor)

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/wisper_interactor`. To experiment with that code, run `bin/console` for an interactive prompt.

TODO: Delete this and the text above, and describe your gem

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
class SampleInteractor

  around do |interactor|
    # ...
    interactor.call
    # ...
  end

  before do
    # ...
  end

  after do
    # ...
  end

  subscribe SampleInteractorListener, async: true

  # Runs after all other hooks when the interactor executes successfully
  on_success do
    broadcast(:sample_interactor_succeeded, *args)
  end

  # Runs in the event of any failure of the interactor
  on_failure do
    broadcast(:sample_interactor_failed, *args)
  end

  perform do
    if form.validate(context)
      form.save
    else
      context.fail!(message: "Failed to create model.")
    end
  end

  def form
    context.form ||= Form.new(Model.new)
  end

  def rollback
    # action to undo if interactor is successful, but needs to
    # be rolled back later, such as when using an Interactor::Organizer
  end
end

SampleInteractor.call(**context)
````

## DSL 

TODO

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

