class CatsRoutes < CatulatorAppServer
  route do |r|
    r.get true do
      cats = api_client.get_cats[:cats]
      view('cats/index', locals: {cats: cats})
    end

    r.post true do
      cat = api_client.create_cat(params.reject { |k, v| v.empty? })
      if cat && cat[:id]
        r.redirect('/cats')
      else
        r.redirect('/cats/create')
      end
    end

    r.get 'create' do
      view('cats/create')
    end

    r.on /(\d+)/ do |cat_id|
      r.post 'delete' do
        api_client.delete_cat(cat_id)
        r.redirect('/cats')
      end
    end
  end
end

