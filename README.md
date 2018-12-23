# RubyLambda

RubyLambda is a toolset for developing and deploying serverless Ruby apps in AWS Lambda.

## Installation

    $ gem install ruby_lambda


## Usage
The main available commands.

```
$ ruby-lambda init
$ ruby-lambda execute
$ ruby-lambda build
$ ruby-lambda deploy
```

### Commands

#### init
```
$ ruby-lambda init
```

Initializes the `event.json`, `main.rb`, `Gemfile`, `.ruby-version` files. `event.json` is where you mock your event.

#### execute
```
$ ruby-lambda execute
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/cookieshq/ruby_lambda. This project is intended to be a welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the RubyLambda project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/ruby_lambda/blob/master/CODE_OF_CONDUCT.md).
