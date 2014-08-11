ENV["RACK_ENV"] = "test"

require_relative "../app"

require "rack/test"
require "minitest"
require "minitest/autorun"
require "minitest/reporters"
require "database_cleaner"
require "uri"

Minitest::Reporters.use!

DatabaseCleaner.strategy = :transaction

Minitest.after_run do
  DB.tables.each do |table|
    DB[table].delete
  end
end

class MiniTest::Spec
  include Rack::Test::Methods

  def app
    CatulatorApp
  end

end
