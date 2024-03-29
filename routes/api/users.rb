require_relative '../api'

class UsersAPIRoutes < APIRoutes
  #/api/users
  route do |r|
    r.get true do
      current_user || unauthorized!
      current_user.role == 'admin' || forbidden!
      halt 200, body: { users: User.all }
    end

    r.post true do
      if params[:role] != 'user'
        current_user || unauthorized!
        current_user.role == 'admin' || forbidden!
      end
      create! User, params
    end

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
      # single user routes, only available to admin or the user
      current_user || unauthorized!
      (current_user.id == user_id.to_i) || (current_user.role == 'admin') || forbidden!
      @user = User[user_id] || not_found!

      r.get true do
        read! @user
      end

      r.put true do
        if params[:role] == 'admin'
          current_user || unauthorized!
          current_user.role == 'admin' || forbidden!
        end
        update! User, @user.id, params
      end

      r.delete true do
        destroy! User, @user.id
      end
    end
  end
end
