class Cat < Sequel::Model
  plugin :validation_helpers

  many_to_one :user

  set_allowed_columns :name, :description, :image_url, :gender, :birthday, :user_id

  def to_hash
    { id: id,
      name: name,
      description: description,
      image_url: image_url,
      gender: gender,
      birthday: birthday,
      owner: { username: user.username,
               name: user.name }
    }
  end

  def to_json(_options = {})
    to_hash.to_json
  end

  private

  def validate
    validates_presence [:name, :user_id]

    super
  end
end
