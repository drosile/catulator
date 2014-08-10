class CatulatorAPIServer < CatulatorServer
  plugin :halt

  def current_user
    return @current_user if @current_user

    token = AccessToken.where(value: token_value).first

    @current_user = token && token.user
  end

  def token_value
    if env['HTTP_AUTHORIZATION']
      auth_type, auth_data = env['HTTP_AUTHORIZATION'].split(' ', 2)
      auth_type.downcase == 'bearer' && auth_data
    else
      params[:access_token]
    end
  end

  def create!(klass, attrs)
    object = klass.new attrs

    error! object.errors unless object.save

    response.status = 201
    object
  end

  def destroy!(klass, id)
    object = klass[id] || not_found!

    error! ['Deletion failed!'] unless object.destroy

    no_content!
  end

  def error!(errors)
    halt 422, body: { success: false, errors: errors }
  end

  def unauthorized!(message = 'unauthorized')
    halt 401, body: { success: false, errors: [message] }
  end

  def no_content!
    halt 204
  end

  def not_found!
    halt 404
  end

  def halt(status, headers: {}, body: '')
    body = body.to_json unless body.is_a? String

    request.halt(status, headers, body)
  end
end
