class AppRoutes < CatulatorAppServer
  route do |r|
    r.get '' do
      view('landing')
    end

    r.post 'login' do
      results = api_client.login(params[:identifier], params[:password])
      if results[:token] && results[:user]
        login(results[:token], results[:user][:username], results[:user][:id])
        r.redirect '/logs'
      else
        r.redirect '/'
      end
    end

    r.post 'logout' do
      results = api_client.logout
      logout
      r.redirect '/'
    end

    r.on 'logs' do
      current_user || r.redirect('/')
      r.run LogsRoutes
    end

    r.on 'cats' do
      current_user || r.redirect('/')
      r.run CatsRoutes
    end
  end
end
