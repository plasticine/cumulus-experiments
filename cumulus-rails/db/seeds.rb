require ::File.expand_path('../../config/environment',  __FILE__)

account = Account.create(:name => "Acme")
metric = Metric.create(:account => account, :type => "page_view", :grains => "response")

Sequel::Model.db.execute <<-SQL
  INSERT INTO account_#{account.id}.metric_#{metric.id} (timestamp, value)

  SELECT
    current_date + ((n - 1) * interval '1 second'),
    RANDOM() * 100

  FROM generate_series(1, 1000000) n;
SQL
