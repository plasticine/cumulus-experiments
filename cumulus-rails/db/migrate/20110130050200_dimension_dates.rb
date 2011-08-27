class DimensionDatesMigration < Sequel::Migration
  def up
    create_table :dimension_dates do
      date :date, :primary_key => true

      Integer :year,    :null => false, :index => true
      Integer :quarter, :null => false, :index => true
      Integer :month,   :null => false, :index => true
      Integer :week,    :null => false, :index => true
      Integer :day,     :null => false, :index => true

      date :nearest_year,    :null => false, :index => true
      date :nearest_quarter, :null => false, :index => true
      date :nearest_month,   :null => false, :index => true
      date :nearest_week,    :null => false, :index => true
    end

    execute %(
      INSERT INTO dimension_dates (
        SELECT
          s.a "date",

          extract(year    from s.a) "year",
          extract(quarter from s.a) "quarter",
          extract(month   from s.a) "month",
          extract(week    from s.a) "week",
          extract(day     from s.a) "day",

          date_trunc('year',    s.a) "nearest_year",
          date_trunc('quarter', s.a) "nearest_quarter",
          date_trunc('month',   s.a) "nearest_month",
          date_trunc('week',    s.a) "nearest_week"
        FROM generate_series('2010-01-01 00:00'::timestamp, '2019-12-31 23:59'::timestamp, '1 day') AS s(a)
      );
    )
  end

  def down
    drop_table :dimension_dates
  end
end
