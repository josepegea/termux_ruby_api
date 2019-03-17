# TermuxRubyApi

TermuxRubyApi is a Gem that provides a Ruby interface to a lot of
Android functionality thanks to [Termux](https://termux.com/) and
[Termux API](https://wiki.termux.com/wiki/Termux:API).


```ruby
require 'termux_ruby_api'

# Connect to the API
t_api = TermuxRubyApi::Base.new

# Get a list of the latest 50 calls
call_log = t_api.call_log.log(limit: 50)

# Get the total seconds spent in outgoing calls
total_duration = call_log.select { |c| c[:type] == :OUTGOING }.map {|c| c[:duration] }.sum

# Get the result in Text To Speak
t_api.tts.speak("The total duration is #{total_duration} seconds")
```

[Termux](https://termux.com/) is a set of Android apps that provide a
complete Debian-like environment for Android, including Ruby, RubyGems
and a whole lot of other packages.

Part of that package, Termux API provides a way to invoke specific
Android functionality, like sending SMS, reading the call log,
accessing the GPS, initiating a phone call and more.

Termux API offers this connection by means of shell scripts that
accept command arguments and return data in JSON format.

TermuxRubyApi provides a convenient access to these scripts from the
confort of a set of Ruby classes that encapsulate all their
functionality and that allows the user to apply all the power and
flexibility of Ruby to access and manipulate this data, interacting
with the Android host.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'termux_ruby_api'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install termux_ruby_api

## Usage

TODO: Write usage instructions here

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/termux_ruby_api. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the TermuxRubyApi project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/termux_ruby_api/blob/master/CODE_OF_CONDUCT.md).
