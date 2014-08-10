require 'date'

Sequel.migration do
  change do
    create_table(:access_tokens) do
      primary_key :id
      foreign_key :user_id, :users, on_delete: :cascade

      String :value, size: 192, null: false
      DateTime :created_at
      DateTime :updated_at
    end
  end
end

