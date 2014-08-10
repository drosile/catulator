require_relative '../api'

class UsersAPIRoutes < APIRoutes
  #/api/users
  route do |r|
    r.post 'authenticate' do
      user = User.authenticate(params[:identifier], params[:password])

      if user
        token = AccessToken.fetch(user_id: user.id)

        result = { token: token.value, user: user.to_hash }
        result.to_json
      else
        unauthorized!
      end
    end

    r.post 'logout' do
      current_user || unauthorized!
      AccessToken.delete(user_id: current_user.id) &&
        { success: true }.to_json || { success: false }.to_json
    end

    r.on /(\d+)/ do |user_id|
      current_user || unauthorized!
      (current_user.id == user_id.to_i) || (current_user.role == 'admin') || forbidden!
      @user = User[user_id] || not_found!

      r.get do
        r.is do
          read! @user
        end
      end

      r.put do
        r.is do
          update! User, @user.id, params
        end
      end
    end

    r.get do
      r.is do
        current_user || unauthorized!
        current_user.role == 'admin' || forbidden!
        halt 200, body: { users: User.all }
      end
    end

    r.post do
      r.is do
        create! User, params
      end
    end
  end
end
