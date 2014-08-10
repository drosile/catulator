require_relative '../helper'

describe 'API' do
  describe 'users' do
    describe 'POST /api/users' do
      it 'creates a new user' do
        user = {
          username: 'test_username',
          name: 'test_user',
          email: 'test_email@email.com',
          password: 'test_password',
          role: 'admin'
        }
        post '/api/users', user

        assert_equal 201, last_response.status
        assert parsed_body[:name]
        assert parsed_body[:email]
        assert !parsed_body[:crypted_password]
      end
    end
  end
end
