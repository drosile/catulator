class LogRoutes < CatulatorAppServer
  route do |r|
    r.is do
      view('log/index')
    end
  end
end

