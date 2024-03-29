class CatulatorAPIClient
  module HTTP
    def get(path, options = {})
      http_request(:get, path, options)
    end

    def post(path, options = {})
      http_request(:post, path, options)
    end

    def put(path, options = {})
      http_request(:put, path, options)
    end

    def delete(path, options = {})
      http_request(:delete, path, options)
    end

    def auth_header
      if @token
        { 'Authorization' => "Bearer #{@token}" }
      else
        {}
      end
    end

    private

    def http_request(method, path, options = {})
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

      response.parsed_response && response.parsed_response.recursive_symbolize_keys!
    end

    def api_url
      ENV['APP_DOMAIN'] + '/api'
    end
  end
end
