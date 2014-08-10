class User < Sequel::Model
  include Shield::Model

  plugin :validation_helpers
  one_to_one :access_token
  one_to_many :cats

  set_allowed_columns :username, :name, :email, :password, :role

  def self.fetch(identifier)
    User[identifier.to_i] ||
      filter(email: identifier).first ||
      filter(username: identifier).first
  end

  def to_hash
    super.tap { |h| h.delete(:crypted_password) }
  end

  def to_json
    to_hash.to_json
  end

  private

  def validate
    validates_presence [:username, :email, :crypted_password, :role]
    validates_unique :username, :email

    super
  end
end
