class CreateAccountsMigration < Sequel::Migration
  def up
    create_table :accounts do
      primary_key :id
      String :name, :null => false, :unique => true
      String :api_key, :null => false, :index => true, :unique => true
      DateTime :created_at, :null => false
      DateTime :updated_at, :null => false
    end
  end

  def down
    drop_table :accounts
  end
end
