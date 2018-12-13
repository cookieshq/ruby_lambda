require 'json'

def lambda_handler(event:, context:)
  # TODO: implement
  { statusCode: 200, body: JSON.generate('Hello from Ruby Lambda') }
end
