class APIRoutes < CatulatorAPIServer
  route do |r|
    response.headers['Content-Type'] = 'application/json'
    r.is do
      'API index'
    end

    r.on 'user' do
      r.run UserAPIRoutes
    end
  end
end

