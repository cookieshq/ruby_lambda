# RubyLambda

RubyLambda is a toolset for developing and deploying serverless Ruby apps in AWS Lambda.


## Installation

    $ gem install ruby_lambda


## Usage
The main available commands.

```
$ ruby-lambda init    # Within the current directory scaffold files needed for a baisc lambda function
$ ruby-lambda execute # Invokes the function locally offline
$ ruby-lambda build   # Build your function into a local ready to deploy zip file
$ ruby-lambda deploy
```

### Commands

#### ruby-lambda init
```
$ ruby-lambda init
```

Initializes the `.gitignore`, `config.yml`, `env`, `event.json`, `lambda_function.rb`, `Gemfile`, `.ruby-version` files.
* `event.json` is where you keep mock data that will be passed to your function when the `execute` command has ran.
* `config.yml` contains some default configuration for your function.
* `env` will be renamed to `.env` after the init command runs, it will contain `AWS_ACCESS_KEY` and `AWS_SECRET_ACCESS_KEY`. You will need these to be able to deploy your function.

Please have a read of the `config.yml` and update any of the default configuration to better suit your function to AWS.

#### ruby-lambda execute
```
$ ruby-lambda execute
```
This command is used to invoke / run the function locally

```
Options:
  -c, [--config=CONFIG] # Default: config.yml
  -H, [--handler=HANDLER]
```

**Examples**
* `$ ruby-lambda execute -c=config.yml`
* `$ ruby-lambda execute -H=lambda_function.handler`

The handler function is the function AWS Lambda will invoke / run in response to an event. AWS Lambda uses the event argument to pass in event data to the handler. If the `handler` flag is passed with execute, this will take precedence over the handler function defined within the `config.yml`

```ruby
def handler(event:, context:)
  { statusCode: 200, body: JSON.generate('Hello from Ruby Lambda') }
end
```

The `execute` command gets the values stored in the `event.json` file and passes them to your handler function.

#### ruby-lambda build
```
$ ruby-lambda build
```
This command will create a zipped file ready to be published on Lambda

```
Options:
  -n, [--native-extensions], [--no-native-extensions]
  -q, [--quiet], [--no-quiet]
```

All output zipped will in the builds folder within the project root - the build folder will be created if one does not already exists.


## Roadmap
Below is the roadmap to version 1

- [ ] Add a way to deploy directly to AWS lambda
- [x] Add ablility to execute the function offline
- [x] Add json file or options to be passed to execute function
- [x] Add a way to build files in to zips ready to be deployed to lambda
- [x] Add the building and zipping of native extentions ready for the lambda environment using docker


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/cookieshq/ruby_lambda. This project is intended to be a welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the RubyLambda project’s codebases and issue trackers is expected to follow the [code of conduct](https://github.com/cookieshq/ruby_lambda/blob/master/CODE_OF_CONDUCT.md).

