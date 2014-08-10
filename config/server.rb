require 'rack/parser'

class CatulatorServer < Roda
  plugin :default_headers
  plugin :indifferent_params

  use Rack::Parser

  def params
    request.params.symbolize_keys!
  end

  def current_user
    return @current_user if @current_user

    token = AccessToken.where(value: token_value).first

    @current_user = token && token.user
  end

  def token_value
    if env['HTTP_AUTHORIZATION']
      auth_type, auth_data = env['HTTP_AUTHORIZATION'].split(' ', 2)
      auth_type.downcase == 'bearer' && auth_data
    else
      params[:access_token]
    end
  end
end
