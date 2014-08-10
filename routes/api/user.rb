class UserAPIRoutes < CatulatorServer
  route do |r|
    r.is '' do
      'You found the users api'
    end
  end
end
