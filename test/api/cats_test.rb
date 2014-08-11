require_relative '../api_helper'

describe 'cats' do
  before do
    @user = User.new({username: 'test_user', password: 'test_pass',
                      email: 'test_email@email.com', role: 'user'})
    @user.save
    @user_token = AccessToken.fetch(user_id: @user.id).value
    @admin = User.new({username: 'test_admin', password: 'test_pass',
                       email: 'test_admin@email.com', role: 'admin'})
    @admin.save
    @admin_token = AccessToken.fetch(user_id: @admin.id).value
    @cat_attrs = {
      name: 'test_cat',
      description: 'stinky',
      gender: 'm',
      image_url: 'test.com',
      birthday: '2014-01-01'
    }
    @cat = Cat.new(@cat_attrs.merge!({ user_id: @user.id }))
    @cat.save
    @admin_cat = Cat.new(@cat_attrs.merge!({ user_id: @admin.id }))
    @admin_cat.save
  end

  describe 'POST /api/cats' do
    it 'creates a new cat' do
      cat_count = Cat.count

      header "Authorization", "Bearer #{@user_token}"
      post '/api/cats', @cat_attrs.merge!({ user_id: @user.id })

      assert_equal 201, last_response.status
      assert_equal cat_count + 1, Cat.count
      assert parsed_body[:name]
      assert parsed_body[:description]
      assert parsed_body[:gender]
      assert parsed_body[:image_url]
      assert parsed_body[:birthday]
    end

    it "doesn't let a non-user create a cat" do
      post '/api/cats', @cat_attrs.merge!({ user_id: @user.id })

      assert_equal 401, last_response.status
    end

    it "doesn't let a non-admin create a cat for someone else" do
      header "Authorization", "Bearer #{@user_token}"
      post '/api/cats', @cat_attrs.merge!({ user_id: @admin.id })

      assert_equal 403, last_response.status
    end

    it "lets an admin create a cat for someone else" do
      cat_count = Cat.count

      header "Authorization", "Bearer #{@admin_token}"
      post '/api/cats', @cat_attrs.merge!({ user_id: @user.id })

      assert_equal cat_count + 1, Cat.count
      assert_equal 201, last_response.status
    end
  end

  describe 'GET /api/cats' do
    it "lets a non-user see cats" do
      get '/api/cats'

      assert_equal 200, last_response.status
      assert parsed_body.key? :cats
    end
  end

  describe 'GET /api/cats/:id' do
    it "lets a non-user see a cat and its owner" do
      get "/api/cats/#{@cat.id}"

      assert_equal 200, last_response.status
      assert parsed_body[:name]
      assert parsed_body[:description]
      assert parsed_body[:gender]
      assert parsed_body[:image_url]
      assert parsed_body[:birthday]
      assert parsed_body[:owner]
    end
  end

  describe 'PUT /api/cats/:id' do
    it "doesn't let a non-user update cats" do
      put "/api/cats/#{@cat.id}", { description: 'smelly' }

      assert_equal 401, last_response.status
    end

    it "lets a non-admin update their own cats" do
      header "Authorization", "Bearer #{@user_token}"
      put "/api/cats/#{@cat.id}", { description: 'smelly' }

      assert_equal 200, last_response.status
      assert_equal 'smelly', parsed_body[:description]
    end

    it "doesn't let a non-admin update other cats" do
      header "Authorization", "Bearer #{@user_token}"
      put "/api/cats/#{@admin_cat.id}", { name: 'updated_name' }

      assert_equal 403, last_response.status
    end

    it "lets an admin update other cats" do
      header "Authorization", "Bearer #{@admin_token}"
      put "/api/cats/#{@cat.id}", { name: 'updated_name' }

      assert_equal 200, last_response.status
      assert_equal 'updated_name', parsed_body[:name]
    end
  end

  describe 'DELETE /api/cats/:id' do
    it "doesn't let a non-user delete cats" do
      delete "/api/cats/#{@cat.id}"

      assert_equal 401, last_response.status
    end

    it "lets a non-admin delete their own cats" do
      header "Authorization", "Bearer #{@user_token}"
      delete "/api/cats/#{@cat.id}"

      assert_equal 204, last_response.status
    end

    it "doesn't let a non-admin delete other cats" do
      header "Authorization", "Bearer #{@user_token}"
      delete "/api/cats/#{@admin_cat.id}"

      assert_equal 403, last_response.status
    end

    it "lets an admin delete other cats" do
      header "Authorization", "Bearer #{@admin_token}"
      delete "/api/cats/#{@cat.id}"

      assert_equal 204, last_response.status
    end
  end
end
