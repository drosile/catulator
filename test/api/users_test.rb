require_relative '../api_helper'

describe 'API' do
  before do
    @user = User.new({username: 'test_user', password: 'test_pass',
                      email: 'test_email@email.com', role: 'user'})
    @user.save
    @user_token = AccessToken.fetch(user_id: @user.id).value
    @admin = User.new({username: 'test_admin', password: 'test_pass',
                       email: 'test_admin@email.com', role: 'admin'})
    @admin.save
    @admin_token = AccessToken.fetch(user_id: @admin.id).value
  end

  describe 'users' do
    describe 'POST /api/users' do
      before do
        @user_attrs = {
          username: 'test',
          name: 'test',
          email: 'test@test.com',
          password: 'test',
          role: 'user'
        }
      end

      it 'creates a new user' do
        post '/api/users', @user_attrs

        assert_equal 201, last_response.status
        assert parsed_body[:name]
        assert parsed_body[:email]
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
        header "Authorization", "Bearer #{@admin_token}"
        post '/api/users', @user_attrs.merge!({ role: 'admin' })

        assert_equal 201, last_response.status
      end
    end
  end
end
