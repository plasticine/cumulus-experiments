require File.expand_path('../../config/environment',  __FILE__)

account = Account.create(name: "Acme")
metric = Metric.create(account: account, type: "page_view", grains: [:resource], properties: [:response_time, :render_time])

Sequel::Model.db.execute <<-SQL
  SET TIME ZONE 'UTC';

  INSERT INTO account_#{account.id}.metric_#{metric.id} (timestamp, count, resource, response_time, render_time)

  SELECT
    current_timestamp - ((n - 1) * interval '1 second'),
    random() * 100,
    (array['/', '/contact', '/about'])[round(random() * 2) + 1],
    random() * 100,
    random() * 1000

  FROM generate_series(1, 1000000) n;
SQL
