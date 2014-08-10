require 'date'

Sequel.migration do
  change do
    create_table(:diabetes_logs) do
      primary_key :id
      foreign_key :cat_id, :cats, on_delete: :cascade

      Integer  :blood_glucose
      Float    :dose_amount
      String   :remarks,       size: 255
      DateTime :timestamp,     null: false
      DateTime :created_at
      DateTime :updated_at
    end
  end
end

