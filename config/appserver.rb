class CatulatorAppServer < CatulatorServer
  use Rack::Session::Cookie, secret: ENV['SECRET']

  plugin :render, engine: 'haml'
  plugin :not_found do
    render('shared/404')
  end
end

