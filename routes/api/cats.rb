require_relative '../api'

class CatsAPIRoutes < APIRoutes
  #/api/cats
  route do |r|
    current_user || unauthorized!
    r.on /(\d+)/ do |cat_id|
      @cat = Cat[cat_id.to_i] || not_found!
      current_user.id == @cat.user_id || forbidden!
      r.get do
        read! @cat
      end

      r.put do
        update! Cat, @cat.id, params.merge!({ user_id: current_user.id })
      end

      r.delete do
        destroy! Cat, @cat.id
      end
    end
    r.get do
      r.is do
        halt 200, body: { cats: current_user.cats }
      end
    end

    r.post do
      create! Cat, params.merge!({ user_id: current_user.id })
    end

  end
end
