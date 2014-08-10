class CatulatorAPIClient
  module Users
    def login(identifier, password)
      data = { identifier: identifier,
               password: password }
      post('users/authenticate', parameters: data)
    end

    def logout
      post('users/logout', headers: auth_header)
    end
  end
end
