Sequel.migration do
  change do
    create_table(:accounts) do
      primary_key :id
      column :name, "text", :null=>false
      column :api_key, "text", :null=>false
      column :created_at, "timestamp without time zone", :null=>false
      column :updated_at, "timestamp without time zone", :null=>false
      
      index [:api_key]
      index [:api_key], :name=>:accounts_api_key_key, :unique=>true
      index [:name], :name=>:accounts_name_key, :unique=>true
    end
    
    create_table(:dimension_dates) do
      column :date, "date", :null=>false
      column :year, "integer", :null=>false
      column :quarter, "integer", :null=>false
      column :month, "integer", :null=>false
      column :week, "integer", :null=>false
      column :day, "integer", :null=>false
      column :nearest_year, "date", :null=>false
      column :nearest_quarter, "date", :null=>false
      column :nearest_month, "date", :null=>false
      column :nearest_week, "date", :null=>false
      
      primary_key [:date]
      
      index [:day]
      index [:month]
      index [:nearest_month]
      index [:nearest_quarter]
      index [:nearest_week]
      index [:nearest_year]
      index [:quarter]
      index [:week]
      index [:year]
    end
    
    create_table(:dimension_times) do
      column :time, "time(0) without time zone", :null=>false
      column :hour, "integer", :null=>false
      column :half_hour, "integer", :null=>false
      column :quarter_hour, "integer", :null=>false
      column :sixth_hour, "integer", :null=>false
      column :twelfth_hour, "integer", :null=>false
      column :minute, "integer", :null=>false
      column :second, "integer", :null=>false
      column :nearest_hour, "time(0) without time zone", :null=>false
      column :nearest_half_hour, "time(0) without time zone", :null=>false
      column :nearest_quarter_hour, "time(0) without time zone", :null=>false
      column :nearest_sixth_hour, "time(0) without time zone", :null=>false
      column :nearest_twelfth_hour, "time(0) without time zone", :null=>false
      column :nearest_minute, "time(0) without time zone", :null=>false
      
      primary_key [:time]
      
      index [:half_hour]
      index [:hour]
      index [:minute]
      index [:nearest_half_hour]
      index [:nearest_hour]
      index [:nearest_minute]
      index [:nearest_quarter_hour]
      index [:nearest_sixth_hour]
      index [:nearest_twelfth_hour]
      index [:quarter_hour]
      index [:second]
      index [:sixth_hour]
      index [:twelfth_hour]
    end
    
    create_table(:schema_migrations) do
      column :filename, "text", :null=>false
      
      primary_key [:filename]
    end
    
    create_table(:metrics) do
      primary_key :id
      foreign_key :account_id, :accounts, :null=>false, :key=>[:id], :on_delete=>:cascade, :on_update=>:cascade
      column :type, "text", :null=>false
      column :grains, "text[]", :null=>false
      column :properties, "text[]", :null=>false
      column :created_at, "timestamp without time zone", :null=>false
      column :updated_at, "timestamp without time zone", :null=>false
      
      index [:type]
    end
  end
end
Sequel.migration do
  change do
    self << "INSERT INTO \"schema_migrations\" (\"filename\") VALUES ('20110130050000_make_date_function.rb')"
    self << "INSERT INTO \"schema_migrations\" (\"filename\") VALUES ('20110130050100_make_time_function.rb')"
    self << "INSERT INTO \"schema_migrations\" (\"filename\") VALUES ('20110130050200_dimension_dates.rb')"
    self << "INSERT INTO \"schema_migrations\" (\"filename\") VALUES ('20110130050300_dimension_times.rb')"
    self << "INSERT INTO \"schema_migrations\" (\"filename\") VALUES ('20110815075519_create_accounts.rb')"
    self << "INSERT INTO \"schema_migrations\" (\"filename\") VALUES ('20110815204404_create_metrics.rb')"
  end
end
