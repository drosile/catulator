require 'rack/parser'

class CatulatorServer < Roda
  plugin :default_headers
  plugin :indifferent_params

  use Rack::Parser

  def params
    request.params.symbolize_keys!
  end
end
