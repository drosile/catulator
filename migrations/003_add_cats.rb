require 'date'

Sequel.migration do
  change do
    create_table(:cats) do
      primary_key :id
      foreign_key :user_id, :users, on_delete: :cascade

      String :name,        size: 255, null: false
      String :description, size: 255
      String :image_url,   size: 255
      String :gender,      size: 1, fixed: true
      DateTime :birthday
      DateTime :created_at
      DateTime :updated_at
    end
  end
end

