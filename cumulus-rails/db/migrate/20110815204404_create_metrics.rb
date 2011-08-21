class CreateMetricsMigration < Sequel::Migration
  def up
    create_table :metrics do
      primary_key :id
      foreign_key :account_id, :accounts, :null => false, :on_delete => :cascade, :on_update => :cascade
      String :name, :null => false, :index => true
      DateTime :created_at, :null => false
      DateTime :updated_at, :null => false
    end
  end

  def down
    drop_table :metrics
  end
end
