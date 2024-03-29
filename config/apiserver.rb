require 'rack/parser'

class CatulatorAPIServer < CatulatorServer
  class RodaResponse
    def initialize(body = [], status = 200, headers = {})
      @body, @headers, @status = [], headers, status
      @length = 0

      @headers['Content-Type'] = 'application/json'

      if body.respond_to? :to_str
        write body.to_str
      elsif body.respond_to? :each
        body.each { |i| write i.to_s }
      else
        fail TypeError, 'body must #respond_to? #to_str or #each'
      end
    end

    def write(data)
      data = data.to_json unless data.is_a? String
      @length += data.bytesize

      body << data
    end

    def finish
      if status == 204
        headers.reject! { |k, _v| ["Content-Type", "Content-Length"].include? k }
      else
        headers['Content-Length'] = @length.to_s
      end

      [status, headers, body]
    end
  end

  plugin :halt
  plugin :all_verbs

  use Rack::Parser

  def current_user
    return @current_user if @current_user

    token = AccessToken.where(value: token_value).first

    @current_user = token && token.user
  end

  def admin?
    current_user && current_user.role == 'admin'
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

    halt 201, body: object.to_json
  end

  def read!(object)
    halt 200, body: object.to_json
  end

  def update!(klass, id, attrs)
    object = klass[id] || not_found!

    object.set attrs

    halt 422, body: { success: false, errors: object.errors } unless object.save

    halt 200, body: object.to_json
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

  def forbidden!(message = 'forbidden')
    halt 403, body: { success: false, errors: [message] }
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
