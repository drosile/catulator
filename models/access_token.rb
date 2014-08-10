class AccessToken < Sequel::Model
  many_to_one :user

  set_allowed_columns :value, :user_id

  def self.fetch(attrs)
    where(attrs).first || create(attrs)
  end

  def self.delete(attrs)
    token = where(attrs).first
    token.destroy if token
  end

  private

  def before_create
    self.value = Shield::Password.generate_salt
  end
end
