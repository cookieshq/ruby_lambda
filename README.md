# RubyLambda [![Build Status](https://travis-ci.org/cookieshq/ruby_lambda.svg?branch=develop)](https://travis-ci.org/cookieshq/ruby_lambda)

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

### ruby-lambda init
```
$ ruby-lambda init
```

Initializes the `.gitignore`, `config.yml`, `env`, `event.json`, `lambda_function.rb`, `Gemfile`, `.ruby-version` files.
* `event.json` is where you keep mock data that will be passed to your function when the `execute` command runs.
* `config.yml` contains some default configuration for your function.
* `env` will be renamed to `.env` after the init command runs, it will contain `AWS_ACCESS_KEY` and `AWS_SECRET_ACCESS_KEY`. You will need these to be able to deploy your function.

Please have a read of the `config.yml` and update any of the default configuration to better suit your function to AWS.

### ruby-lambda execute
```
$ ruby-lambda execute
```
This command is used to invoke / run the function locally

```
Options:
  -c, --config=CONFIG # Default: config.yml
  -H, --handler=HANDLER
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

### ruby-lambda build
```
$ ruby-lambda build
```
This command will create a zipped file ready to be published on Lambda

```
Options:
  -n, --native-extensions
  -q, --quiet
```

All output zipped will in the builds folder within the project root - the build folder will be created if one does not already exists.

**Native Extensions**

This [article](http://patshaughnessy.net/2011/10/31/dont-be-terrified-of-building-native-extensions) covers what native extensions are and a lot more information about how they work. Basically, building native extensions are nothing but compiling C code into the platform and environment specific machine language code. So, if you run bundle install — deployment on your local machine running MacOS, the C code is compiled for MacOS and stored in vendor/bundle. As AWS lambda is a Ubuntu machine, not MacOs it won’t work.

To build gems with Native extensions use `-n` flag when you run this command. Doing so will run a dockerized bundle with deployment flag within a Lambda image – this will download the gems to the local directory instead of to the local systems Ruby directory, using the same OS environment as Lambda so that it installs the correct native extensions. This ensures that all our dependencies are included in the function deployment package and the correct native extensions will be called.


### ruby-lambda deploy
```
$ ruby-lambda deploy

```
The deploy command will either bundle install your project and package it in a zip or accept a zip file passed to it then uploads it to AWS Lambda.

```
Options:
    -n, --native-extensions flag to pass build gems with native extensions
    -c, --config=CONFIG path to the config file, defalt is config.yml
    -p, --publish if the function should be published, default is true
    -u, --update default to true, update the function
    -z, --zip-file=ZIP_FILE path to zip file to create or update your function
    -q, --quiet
```

By default the `deploy` command will attepmt to create the function with your config, if the function already exists an error will be thrown. To update an existing function simply pass the `-u` flag.


When you publish a version, AWS Lambda makes a snapshot copy of the Lambda function code (and configuration) in the $LATEST version. A published version is immutable. That is, you can't change the code or configuration information. The new version has a unique ARN that includes a version number suffix. AWS recommends that you publish a version at the same time that you create your Lambda function or update your Lambda function code. So by default all deploy will be versioned, if you do not want this, use `-p=false` flag.

When you run the deploy command we will prepare the latest state of your function and zip it up, basically running the build command. If you have already built your zip, use the `-z` flag to set the path to it.

## Roadmap

- [ ] Add an option to add APIGate way to allow functions to have an end point
- [ ] Add the ability to deploy different ruby versions using layers
- [ ] Add an options to choose zip uploaded to s3
- [ ] Add option to allow deploy to use value passed through the flags
- [ ] Add more deploy options
- [ ] Add environment variables to be passed in deploying
- [x] Add a way to deploy and update Lambda functions
- [x] Add ablility to execute the function offline
- [x] Add json file or options to be passed to execute function
- [x] Add a way to build files in to zips ready to be deployed to lambda
- [x] Add the building and zipping of native extentions ready for the lambda environment using docker


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/cookieshq/ruby_lambda. This project is intended to be a welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the RubyLambda project’s codebases and issue trackers is expected to follow the [code of conduct](https://github.com/cookieshq/ruby_lambda/blob/master/CODE_OF_CONDUCT.md).
