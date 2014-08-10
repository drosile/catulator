class DiabetesLog < Sequel::Model
  plugin :validation_helpers

  many_to_one :cat

  set_allowed_columns :cat_id, :blood_glucose, :dose_amount, :remarks, :timestamp

  def to_json(_options = {})
    to_hash.to_json
  end

  private

  def validate
    validates_presence [:timestamp]
    validates_length_range 0..255, :remarks

    super
  end
end
