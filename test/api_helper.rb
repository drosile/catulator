require_relative "helper"

class MiniTest::Spec
  def parsed_body
    @body ||= JSON.parse last_response.body, symbolize_names: true
  end

  def post(uri, data = {}, *opts)
    super(uri, data.to_json, *opts)
  end

  def put(uri, data = {}, *opts)
    super(uri, data.to_json, *opts)
  end

  before do
    header "Accept", "application/json"
    header "Content-Type", "application/json"

    DatabaseCleaner.start
  end

  after do
    DatabaseCleaner.clean
  end
end
