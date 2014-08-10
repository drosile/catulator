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
      results = api_client.login(params[:identifier], params[:password])
      if results[:token] && results[:user]
        login(results[:token], results[:user]["username"])
        r.redirect '/log'
      else
        r.redirect '/login'
      end
    end

    r.get 'logout' do
      results = api_client.logout
      logout
      r.redirect '/login'
    end


    r.on 'log' do
      r.run LogRoutes
    end
  end
end
