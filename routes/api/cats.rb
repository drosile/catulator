require_relative '../api'

class CatsAPIRoutes < APIRoutes
  #/api/cats
  route do |r|
    r.on /(\d+)/ do |cat_id|
      @cat = Cat[cat_id.to_i] || not_found!
      r.get true do
        read! @cat
      end

      r.put true do
        current_user || unauthorized!
        (current_user.id == @cat.user_id) || admin? || forbidden!

        update! Cat, @cat.id, params.merge!({ user_id: current_user.id })
      end

      r.delete true do
        current_user || unauthorized!
        (current_user.id == @cat.user_id) || admin? || forbidden!

        destroy! Cat, @cat.id
      end
    end

    r.get true do
      halt 200, body: { cats: Cat.all }
    end

    r.post true do
      current_user || unauthorized!
      if params[:user_id]
        (params[:user_id].to_i == current_user.id) || admin? || forbidden!
      else
        params.merge!({ user_id: current_user.id })
      end
      create! Cat, params
    end
  end
end
