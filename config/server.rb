class CatulatorServer < Roda
  plugin :default_headers
  plugin :indifferent_params

  def params
    request.params.symbolize_keys!
  end
end
