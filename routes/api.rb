class APIRoutes < CatulatorAPIServer
  route do |r|
    response.headers['Content-Type'] = 'application/json'
    r.is do
      'API index'
    end

    r.on 'users' do
      r.run UsersAPIRoutes
    end
  end
end

