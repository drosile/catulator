require_relative '../lib/api-client'

class CatulatorAppServer < CatulatorServer
  use Rack::Session::Cookie, secret: ENV['SECRET']

  plugin :render, engine: 'haml'
  plugin :not_found do
    render('shared/404')
  end

  def login(user_token, username)
    session[:user] = {
      token: user_token,
      username: username
    }
  end

  def logout
    session.delete(:user)
  end

  def current_user
    session[:user]
  end
end

