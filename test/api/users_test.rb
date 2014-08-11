require_relative '../api_helper'

describe 'users' do
  before do
    @user = User.new({username: 'test_user', password: 'test_pass',
                      email: 'test_email@email.com', role: 'user'})
    @user.save
    @user_token = AccessToken.fetch(user_id: @user.id).value
    @admin = User.new({username: 'test_admin', password: 'test_pass',
                       email: 'test_admin@email.com', role: 'admin'})
    @admin.save
    @admin_token = AccessToken.fetch(user_id: @admin.id).value
    @user_attrs = {
      username: 'test',
      email: 'test@test.com',
      password: 'test',
      role: 'user'
    }
  end

  describe 'POST /api/users' do
    it 'creates a new user' do
      user_count = User.count

      post '/api/users', @user_attrs

      assert_equal 201, last_response.status
      assert_equal user_count + 1, User.count
      assert parsed_body[:username]
      assert parsed_body[:email]
      assert parsed_body[:role]
      assert !parsed_body[:crypted_password]
    end

    it "doesn't let a non-user create an admin" do
      post '/api/users', @user_attrs.merge!({ role: 'admin' })

      assert_equal 401, last_response.status
    end

    it "doesn't let a non-admin create an admin" do
      header "Authorization", "Bearer #{@user_token}"
      post '/api/users', @user_attrs.merge!({ role: 'admin' })

      assert_equal 403, last_response.status
    end

    it "lets an admin create an admin" do
      user_count = User.count

      header "Authorization", "Bearer #{@admin_token}"
      post '/api/users', @user_attrs.merge!({ role: 'admin' })

      assert_equal user_count + 1, User.count
      assert_equal 201, last_response.status
    end
  end

  describe 'GET /api/users' do
    it "doesn't let a non-user see users" do
      get '/api/users'

      assert_equal 401, last_response.status
    end

    it "doesn't let a non-admin see users" do
      header "Authorization", "Bearer #{@user_token}"
      get '/api/users'

      assert_equal 403, last_response.status
    end

    it "lets an admin see all users" do
      user_count = User.count

      header "Authorization", "Bearer #{@admin_token}"
      get '/api/users'

      assert_equal 200, last_response.status
      assert_equal user_count, parsed_body[:users].length
    end
  end

  describe 'GET /api/users/:id' do
    it "doesn't let a non-user see users" do
      get "/api/users/#{@user.id}"

      assert_equal 401, last_response.status
    end

    it "lets a non-admin see themself" do
      header "Authorization", "Bearer #{@user_token}"
      get "/api/users/#{@user.id}"

      assert_equal 200, last_response.status
      assert_equal @user.id, parsed_body[:id]
    end

    it "doesn't let a non-admin see other users" do
      header "Authorization", "Bearer #{@user_token}"
      get "/api/users/#{@admin.id}"

      assert_equal 403, last_response.status
    end

    it "lets an admin see all users" do
      user_count = User.count

      header "Authorization", "Bearer #{@admin_token}"
      get "/api/users/#{@user.id}"

      assert_equal 200, last_response.status
      assert_equal @user.id, parsed_body[:id]
    end
  end

  describe 'PUT /api/users/:id' do
    it "doesn't let a non-user update users" do
      put "/api/users/#{@user.id}", { name: 'updated_name' }

      assert_equal 401, last_response.status
    end

    it "lets a non-admin update themself" do
      header "Authorization", "Bearer #{@user_token}"
      put "/api/users/#{@user.id}", { name: 'updated_name' }

      assert_equal 200, last_response.status
      assert_equal 'updated_name', parsed_body[:name]
    end

    it "doesn't let a non-admin make themself an admin" do
      header "Authorization", "Bearer #{@user_token}"
      put "/api/users/#{@user.id}", { role: 'admin' }

      assert_equal 403, last_response.status
    end

    it "doesn't let a non-admin update other users" do
      header "Authorization", "Bearer #{@user_token}"
      put "/api/users/#{@admin.id}", { name: 'updated_name' }

      assert_equal 403, last_response.status
    end

    it "lets an admin update other users" do
      header "Authorization", "Bearer #{@admin_token}"
      put "/api/users/#{@user.id}", { name: 'updated_name' }

      assert_equal 200, last_response.status
      assert_equal 'updated_name', parsed_body[:name]
    end
  end

  describe 'DELETE /api/users/:id' do
    it "doesn't let a non-user delete users" do
      delete "/api/users/#{@user.id}"

      assert_equal 401, last_response.status
    end

    it "lets a non-admin delete themself" do
      header "Authorization", "Bearer #{@user_token}"
      delete "/api/users/#{@user.id}"

      assert_equal 204, last_response.status
    end

    it "doesn't let a non-admin delete other users" do
      header "Authorization", "Bearer #{@user_token}"
      delete "/api/users/#{@admin.id}"

      assert_equal 403, last_response.status
    end

    it "lets an admin delete other users" do
      header "Authorization", "Bearer #{@admin_token}"
      delete "/api/users/#{@user.id}"

      assert_equal 204, last_response.status
    end
  end

  describe 'POST /api/users/authenticate' do
    it 'authenticates with valid credentials and provides a token' do
      post '/api/users/authenticate', { identifier: "test_user", password: "test_pass" }

      assert_equal 200, last_response.status
      assert parsed_body[:token]
    end

    it "doesn't authenticate with valid credentials" do
      post '/api/users/authenticate', { identifier: "wrong_user", password: "test_pass" }

      assert_equal 401, last_response.status
    end
  end

  describe 'POST /api/users/logout' do
    it 'logs out the current user and destroys the token' do
      assert_equal 1, AccessToken.where(value: @user_token).count

      header "Authorization", "Bearer #{@user_token}"
      post '/api/users/logout'

      assert_equal 200, last_response.status
      assert parsed_body[:success]
      assert_equal 0, AccessToken.where(value: @user_token).count
    end

    it 'returns a 401 if no token is given' do
      post '/api/users/logout'

      assert_equal 401, last_response.status
    end
  end
end
