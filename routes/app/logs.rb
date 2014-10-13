class LogRoutes < CatulatorAppServer
  route do |r|
    r.is do
      view('logs/index')
    end
  end
end

