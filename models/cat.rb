class Cat < Sequel::Model
  plugin :validation_helpers

  many_to_one :user

  set_allowed_columns :name, :description, :image_url, :gender, :birthday, :user_id

  private

  def validate
    validates_presence [:name, :user_id]

    super
  end
end
