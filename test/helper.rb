ENV["RACK_ENV"] = "test"

require_relative "../app"

require "rack/test"
require "minitest"
require "minitest/autorun"
require "minitest/reporters"
require "uri"

Minitest::Reporters.use!

Minitest.after_run do
  DB.tables.each do |table|
    DB[table].delete
  end
end

class MiniTest::Spec
  include Rack::Test::Methods

  def parsed_body
    @body ||= JSON.parse last_response.body, symbolize_names: true
  end

  def post(uri, data = {}, *opts)
    super(uri, data.to_json, *opts)
  end

  def put(uri, data = {} *opts)
    super(uri, data.to_json, *opts)
  end

  def app
    CatulatorApp
  end

  before do
    header "Accept", "application/json"
    header "Content-Type", "application/json"
  end
end
