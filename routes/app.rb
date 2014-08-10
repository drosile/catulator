class AppRoutes < CatulatorAppServer
  route do |r|
    r.is '' do
      current_user && r.redirect('/log')
      r.redirect '/login'
    end

    r.get 'login' do
      view('login')
    end

    r.post 'login' do
      data = { identifier: params[:identifier],
               password: params[:password] }
      require 'pry'; binding.pry
      results = CatulatorAPIClient.post('user/authenticate',
                                        parameters: data)
      if results[:token] && results[:user]
        login(results[:token], results[:user][:username])
        r.redirect '/log'
      else
        r.redirect '/login'
      end
    end

    r.on 'log' do
      r.run LogRoutes
    end
  end
end
