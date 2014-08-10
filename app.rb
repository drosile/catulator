require 'roda'
require 'haml'
require 'rack'
require 'tilt'

require_relative 'config/server'

Dir['./routes/**/*.rb'].each { |file| require file }

class CatulatorApp < CatulatorServer
  use Rack::Session::Cookie, secret: ENV['SECRET']

  plugin :default_headers
  plugin :indifferent_params
  plugin :render, engine: 'haml'
  plugin :not_found do
    render('shared/404')
  end

  route do |r|
    r.get do
      r.is '' do
        r.redirect '/log'
      end

      r.on 'log' do
        r.run LogRoutes
      end

      r.on 'api' do
        r.run APIRoutes
      end
    end
  end
end
