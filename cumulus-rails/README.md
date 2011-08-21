# Cumulus

## Quickstart

    > git clone git@github.com:nullobject/cumulus.git
    > cd cumulus
    > gem install bundler
    > bundle
    > cp config/database.yml.example config/database.yml
    > rake

## Generate some data

    INSERT INTO metric_1 (timestamp, value)

    SELECT
      current_date + ((n - 1) * interval '1 second'),
      RANDOM() * 100

    FROM generate_series(1, 1000000) n;
