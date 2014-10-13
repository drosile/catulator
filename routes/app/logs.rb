class LogsRoutes < CatulatorAppServer
  route do |r|
    r.get true do
      logs = api_client.get_logs[:diabetes_logs]
      view('logs/index', locals: { logs: logs })
    end

    r.post true do
      log = api_client.create_log(params.reject { |k, v| v.empty? })
      if log && log[:id]
        r.redirect('/logs')
      else
        r.redirect('/logs/create')
      end
    end

    r.get 'create' do
      cats = api_client.get_cats[:cats]
      view('logs/create', locals: { cats: cats })
    end
  end
end

