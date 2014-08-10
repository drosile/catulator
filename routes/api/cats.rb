require_relative '../api'

class CatsAPIRoutes < APIRoutes
  #/api/cats
  route do |r|
    r.on /(\d+)/ do |cat_id|
      @cat = Cat[cat_id.to_i] || not_found!
      r.get do
        r.is do
          read! @cat
        end
      end

      r.put do
        current_user || unauthorized!
        current_user.id == @cat.user_id || forbidden!
        r.is do
          update! Cat, @cat.id, params.merge!({ user_id: current_user.id })
        end
      end

      r.delete do
        current_user || unauthorized!
        current_user.id == @cat.user_id || forbidden!
        r.is do
          destroy! Cat, @cat.id
        end
      end
    end

    r.get do
      r.is do
        halt 200, body: { cats: Cat.all }
      end
    end

    r.post do
      current_user || unauthorized!
      r.is do
        create! Cat, params.merge!({ user_id: current_user.id })
      end
    end
  end
end
