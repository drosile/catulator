class UserAPIRoutes < APIRoutes
  #/api/user
  route do |r|
    r.is do
      'User api index'
    end

    r.post 'authenticate' do
      #require 'pry';binding.pry
      user = User.authenticate(params[:identifier], params[:password])

      if user
        token = AccessToken.fetch(user_id: user.id)

        result = { token: token.value, user: user.to_hash }
        result.to_json
      else
        'not authed'
      end
    end

    r.post 'logout' do
      current_user || unauthorized!
      AccessToken.delete(user_id: current_user.id) &&
        { success: true }.to_json
      'failed'
    end

    r.on /(\d+)/ do |user_id|
      r.is do
        user = User[user_id]
        user.to_hash.to_json
      end
    end

  end
end
