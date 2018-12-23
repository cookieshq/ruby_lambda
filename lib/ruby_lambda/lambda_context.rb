module RubyLambda
  class LambdaContext

    attr_reader :aws_request_id, :clock_diff, :deadline_ms, :function_name, :function_version, :invoked_function_arn, :log_group_name, :log_stream_name, :memory_limit_in_mb

    def initialize
      @aws_request_id       = "c089f0e4-022d-11e9-a659-a36fee2f4cdb"
      @clock_diff           = 1545072475011
      @deadline_ms          = 1545073117036
      @function_name        = "ruby-lambda"
      @function_version     = "$LATEST"
      @invoked_function_arn = "arn:aws:lambda:eu-west-2:537022253312:function:ruby-lambda"
      @log_group_name       = "/aws/lambda/ruby-lambda"
      @log_stream_name      = "2018/12/17/[$LATEST]b367aa21dad14637a7bd7cc483992b4d"
      @memory_limit_in_mb   = "128"
    end
  end
end
