require_relative '../api_helper'

describe 'diabetes logs' do
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
    @log_attrs = {
      cat_id: @cat.id,
      blood_glucose: 150,
      dose_amount: 0.25,
      remarks: "he stinks!",
      timestamp: "2000-01-01 12:00:00"
    }
  end

  describe 'POST /api/logs' do
    it 'creates a new log entry' do
      log_count = DiabetesLog.count

      header "Authorization", "Bearer #{@user_token}"
      post '/api/logs', @log_attrs

      assert_equal 201, last_response.status
      assert_equal log_count + 1, DiabetesLog.count
      assert_equal @cat.id,  parsed_body[:cat_id]
      assert_equal 150, parsed_body[:blood_glucose]
      assert_equal 0.25, parsed_body[:dose_amount]
      assert_equal "he stinks!", parsed_body[:remarks]
      assert parsed_body[:timestamp]
    end

    it 'sets the current datetime if not provided' do
      log_count = DiabetesLog.count
      @log_attrs[:timestamp] = nil

      header "Authorization", "Bearer #{@user_token}"
      post '/api/logs', @log_attrs

      assert_equal 201, last_response.status
      assert parsed_body[:timestamp]
    end

    it "doesn't let a non-user create a log entry" do
      post '/api/logs', @log_attrs

      assert_equal 401, last_response.status
    end

    it "doesn't let a non-admin create a log entry for someone else's cat" do
      header "Authorization", "Bearer #{@user_token}"
      post '/api/logs', @log_attrs.merge!({ cat_id: @admin_cat.id })

      assert_equal 403, last_response.status
    end

    it "lets an admin create a log entry for someone else's cat" do
      log_count = DiabetesLog.count

      header "Authorization", "Bearer #{@admin_token}"
      post '/api/logs', @log_attrs.merge!({ cat_id: @cat.id })

      assert_equal 201, last_response.status
      assert_equal log_count + 1, DiabetesLog.count
    end

    it 'works with only dose amount and cat ID' do
      log_count = DiabetesLog.count

      attrs = {
        cat_id: @cat.id,
        blood_glucose: 150,
      }

      header "Authorization", "Bearer #{@user_token}"
      post '/api/logs', attrs

      assert_equal 201, last_response.status
      assert_equal log_count + 1, DiabetesLog.count
      assert_equal @cat.id,  parsed_body[:cat_id]
      assert_equal 150, parsed_body[:blood_glucose]
      assert parsed_body[:timestamp]
    end

  end

  describe 'GET /api/logs' do
    it "lets a non-user see log entries" do
      get '/api/logs'

      assert_equal 200, last_response.status
      assert parsed_body.key? :diabetes_logs
    end
  end

  describe 'GET /api/logs/:id' do
    before do
      @log = DiabetesLog.new(@log_attrs)
      @log.save
    end

    it "lets a non-user see an individual log entry" do
      get "/api/logs/#{@log.id}"

      assert_equal 200, last_response.status
      assert_equal @cat.id,  parsed_body[:cat_id]
      assert_equal 150, parsed_body[:blood_glucose]
      assert_equal 0.25, parsed_body[:dose_amount]
      assert_equal "he stinks!", parsed_body[:remarks]
    end
  end

  describe 'PUT /api/cats/:id' do
    before do
      @log = DiabetesLog.new(@log_attrs)
      @log.save
      @admin_log = DiabetesLog.new(@log_attrs.merge!({ cat_id: @admin_cat.id }))
      @admin_log.save
    end

    it "doesn't let a non-user update logs" do
      put "/api/logs/#{@log.id}", { remarks: 'smelly' }

      assert_equal 401, last_response.status
    end

    it "lets a non-admin update their own logs" do
      header "Authorization", "Bearer #{@user_token}"
      put "/api/logs/#{@log.id}", { remarks: 'smelly' }

      assert_equal 200, last_response.status
      assert_equal 'smelly', parsed_body[:remarks]
    end

    it "doesn't let a non-admin update other logs" do
      header "Authorization", "Bearer #{@user_token}"
      put "/api/logs/#{@admin_log.id}", { remarks: 'smelly' }

      assert_equal 403, last_response.status
    end

    it "lets an admin update other logs" do
      header "Authorization", "Bearer #{@admin_token}"
      put "/api/logs/#{@log.id}", { remarks: 'smelly' }

      assert_equal 200, last_response.status
      assert_equal 'smelly', parsed_body[:remarks]
    end
  end

  describe 'DELETE /api/logs/:id' do
    before do
      @log = DiabetesLog.new(@log_attrs)
      @log.save
      @admin_log = DiabetesLog.new(@log_attrs.merge!({ cat_id: @admin_cat.id }))
      @admin_log.save
    end

    it "doesn't let a non-user delete logs" do
      delete "/api/logs/#{@log.id}"

      assert_equal 401, last_response.status
    end

    it "lets a non-admin delete their own logs" do
      header "Authorization", "Bearer #{@user_token}"
      delete "/api/logs/#{@log.id}"

      assert_equal 204, last_response.status
    end

    it "doesn't let a non-admin delete other logs" do
      header "Authorization", "Bearer #{@user_token}"
      delete "/api/logs/#{@admin_log.id}"

      assert_equal 403, last_response.status
    end

    it "lets an admin delete other logs" do
      header "Authorization", "Bearer #{@admin_token}"
      delete "/api/logs/#{@log.id}"

      assert_equal 204, last_response.status
    end
  end
end
