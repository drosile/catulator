require 'httparty'
require 'json'

require_relative 'api-client/http'
require_relative 'api-client/users'
require_relative 'api-client/cats'
require_relative 'api-client/logs'

# for accessing my own API
class CatulatorAPIClient
  include CatulatorAPIClient::HTTP
  include CatulatorAPIClient::Users
  include CatulatorAPIClient::Cats
  include CatulatorAPIClient::Logs

  def initialize(token = nil)
    @token = token
  end
end

