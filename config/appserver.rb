require_relative '../lib/api-client'

class CatulatorAppServer < CatulatorServer
  use Rack::Session::Cookie, secret: ENV['SECRET']

  plugin :render, engine: 'haml'
  plugin :not_found do
    view('shared/404')
  end

  def login(token, username, id)
    session[:user] = {
      token: token,
      username: username,
      id: id
    }
    api_client = CatulatorAPIClient.new(token)
  end

  def logout
    session.delete(:user)
    api_client = CatulatorAPIClient.new
  end

  def current_user
    session[:user]
  end

  def api_client
    token = current_user && current_user[:token]
    @api_client ||= CatulatorAPIClient.new(token)
  end

  def api_client=(client)
    @api_client = client
  end
end

