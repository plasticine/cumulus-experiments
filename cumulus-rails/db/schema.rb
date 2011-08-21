Sequel.migration do
  up do
    create_table(:accounts, :ignore_index_errors=>true) do
      primary_key :id
      String :name, :text=>true, :null=>false
      String :api_key, :text=>true, :null=>false
      DateTime :created_at, :null=>false
      DateTime :updated_at, :null=>false
      
      index [:api_key]
      index [:api_key], :name=>:accounts_api_key_key, :unique=>true
      index [:name], :name=>:accounts_name_key, :unique=>true
    end
    
    create_table(:dimension_dates, :ignore_index_errors=>true) do
      Date :date, :null=>false
      Integer :year, :null=>false
      Integer :quarter, :null=>false
      Integer :month, :null=>false
      Integer :week, :null=>false
      Integer :day, :null=>false
      Date :nearest_year, :null=>false
      Date :nearest_quarter, :null=>false
      Date :nearest_month, :null=>false
      Date :nearest_week, :null=>false
      
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
    
    create_table(:dimension_times, :ignore_index_errors=>true) do
      String :time, :null=>false
      Integer :hour, :null=>false
      Integer :half_hour, :null=>false
      Integer :quarter_hour, :null=>false
      Integer :sixth_hour, :null=>false
      Integer :twelfth_hour, :null=>false
      Integer :minute, :null=>false
      Integer :second, :null=>false
      String :nearest_hour, :null=>false
      String :nearest_half_hour, :null=>false
      String :nearest_quarter_hour, :null=>false
      String :nearest_sixth_hour, :null=>false
      String :nearest_twelfth_hour, :null=>false
      String :nearest_minute, :null=>false
      
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
    
    create_table(:metrics, :ignore_index_errors=>true) do
      primary_key :id
      Integer :account_id, :null=>false
      String :name, :text=>true, :null=>false
      DateTime :created_at, :null=>false
      DateTime :updated_at, :null=>false
      
      index [:name]
    end
    
    create_table(:schema_migrations) do
      String :filename, :text=>true, :null=>false
      
      primary_key [:filename]
    end
  end
  
  down do
    drop_table(:accounts, :dimension_dates, :dimension_times, :metrics, :schema_migrations)
  end
end
