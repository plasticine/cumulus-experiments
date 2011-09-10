class DimensionTimesMigration < Sequel::Migration
  def up
    create_table :dimension_times do
      time :time, size: 0, primary_key: true

      Integer :hour,         null: false, index: true
      Integer :half_hour,    null: false, index: true
      Integer :quarter_hour, null: false, index: true
      Integer :sixth_hour,   null: false, index: true
      Integer :twelfth_hour, null: false, index: true
      Integer :minute,       null: false, index: true
      Integer :second,       null: false, index: true

      time :nearest_hour,         size: 0, null: false, index: true
      time :nearest_half_hour,    size: 0, null: false, index: true
      time :nearest_quarter_hour, size: 0, null: false, index: true
      time :nearest_sixth_hour,   size: 0, null: false, index: true
      time :nearest_twelfth_hour, size: 0, null: false, index: true
      time :nearest_minute,       size: 0, null: false, index: true
    end

    execute %(
      INSERT INTO dimension_times (
        SELECT
          s.a "time",

          extract(hour from s.a)                          "hour",
          ((extract(minute from s.a)::integer / 10) * 30) "half_hour",
          ((extract(minute from s.a)::integer / 10) * 15) "quarter_hour",
          ((extract(minute from s.a)::integer / 10) * 10) "sixth_hour",
          ((extract(minute from s.a)::integer / 5)  *  5) "twelfth_hour",
          extract(minute from s.a)                        "minute",
          extract(second from s.a)                        "second",

          make_time(extract(hour from s.a)::integer,                                             0) "nearest_hour",
          make_time(extract(hour from s.a)::integer, (extract(minute from s.a)::integer / 30) * 30) "nearest_half_hour",
          make_time(extract(hour from s.a)::integer, (extract(minute from s.a)::integer / 15) * 15) "nearest_quarter_hour",
          make_time(extract(hour from s.a)::integer, (extract(minute from s.a)::integer / 10) * 10) "nearest_sixth_hour",
          make_time(extract(hour from s.a)::integer, (extract(minute from s.a)::integer / 5)  *  5) "nearest_twelfth_hour",
          make_time(extract(hour from s.a)::integer, extract(minute from s.a)::integer            ) "nearest_minute"
        FROM generate_series('2010-01-01 00:00:00'::timestamp, '2010-01-01 23:59:59'::timestamp, '1 second') AS s(a)
      );
    )
  end

  def down
    drop_table :dimension_times
  end
end
