class APIRoutes < CatulatorAPIServer
  route do |r|
    response.headers['Content-Type'] = 'application/json'

    r.on 'users' do
      r.run UsersAPIRoutes
    end

    r.on 'cats' do
      r.run CatsAPIRoutes
    end

    r.on 'logs' do
      r.run DiabetesLogsAPIRoutes
    end
  end
end

