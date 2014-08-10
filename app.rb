require 'roda'
require 'haml'
require 'rack'
require 'tilt'
require 'dotenv'
require 'shield'

Dotenv.load


require_relative 'config/db'
require_relative 'config/server'
require_relative 'config/apiserver'
require_relative 'config/appserver'

Dir['./lib/**/*.rb'].each    { |file| require file }
Dir['./models/**/*.rb'].each { |file| require file }
Dir['./routes/**/*.rb'].each { |file| require file }

class CatulatorApp < CatulatorServer
  route do |r|
    r.on do
      r.on 'api' do
        r.run APIRoutes
      end

      r.run AppRoutes
    end
  end
end
