require 'httparty'
require 'json'

# for accessing my own API
class CatulatorAPIClient
  def self.get(path, options = {})
    http_request(:get, path, options)
  end

  def self.post(path, options = {})
    http_request(:post, path, options)
  end

  private

  def self.http_request(method, path, options = {})
    headers = options.fetch(:headers, {}).dup
    parameters = options.fetch(:parameters, {})

    arguments = { headers: headers }

    if method == :get
      arguments[:query] = parameters
    else
      headers['Content-Type'] = 'application/json'
      arguments[:body] = JSON.generate(parameters)
    end

    url = URI.encode("#{api_url}/#{path}")
    response = HTTParty.send(method, url, arguments)

    JSON.parse(response.parsed_response).symbolize_keys!
  end

  def self.api_url
    ENV['APP_DOMAIN'] + '/api'
  end
end
