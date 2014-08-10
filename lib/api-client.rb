require 'httparty'
require 'json'

require_relative 'api-client/http'
require_relative 'api-client/users'

# for accessing my own API
class CatulatorAPIClient
  include CatulatorAPIClient::HTTP
  include CatulatorAPIClient::Users

  def initialize(token = nil)
    @token = token
  end
end

