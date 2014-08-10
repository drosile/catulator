require 'sequel'
require 'pg'

DB = Sequel.connect ENV['DB']

Sequel::Model.plugin :association_dependencies
Sequel::Model.plugin :json_serializer
Sequel::Model.plugin :timestamps
Sequel::Model.plugin :validation_helpers

Sequel.default_timezone = :utc
