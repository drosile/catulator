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
      current_user && current_user.id == user_id.to_i || unauthorized!
      r.is do
        user = User[user_id]
        user.to_hash.to_json
      end
    end
  end
end
