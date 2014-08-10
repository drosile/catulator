class CatulatorAPIServer < CatulatorServer
  plugin :halt

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
