require 'date'

Sequel.migration do
  change do
    create_table(:users) do
      primary_key :id

      String :username,         size: 64,  null: false
      String :name,             size: 128, null: true
      String :email,            size: 128, null: false
      String :crypted_password, size: 192, null: false
      String :role,             size: 32,  null: false
      DateTime :created_at
      DateTime :updated_at
    end
  end
end

