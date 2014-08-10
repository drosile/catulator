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
        token = 'abcdefg'

        result = { token: token, user: user.to_hash }
        result.to_json
      else
        'not authed'
      end
    end

    r.on /(\d+)/ do |user_id|
      r.is do
        user = User[user_id]
        user.to_hash.to_json
      end
    end

  end
end
