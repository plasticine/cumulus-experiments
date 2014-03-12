require File.expand_path('../../config/environment',  __FILE__)

account = Account.create(name: "Acme")
metric = Metric.create(account: account, type: "page_view", grains: [:resource], properties: [:response_time])

Sequel::Model.db.execute <<-SQL
  INSERT INTO account_#{account.id}.metric_#{metric.id} (timestamp, count, resource, sum_response_time, avg_response_time, min_response_time, max_response_time)

  SELECT
    current_date + ((n - 1) * interval '1 second'),
    random() * 100,
    (array['/', '/contact', '/about'])[round(random() * 2) + 1],
    random() * 100,
    random() * 100,
    random() * 100,
    random() * 100

  FROM generate_series(1, 1000000) n;
SQL
