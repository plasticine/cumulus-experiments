class MakeTimeFunctionMigration < Sequel::Migration
  def up
    execute %(
      CREATE OR REPLACE FUNCTION make_time(anyelement, anyelement)
      RETURNS time AS $$
        SELECT ($1 || ':' || $2)::time;
      $$ LANGUAGE SQL;
    )
  end

  def down
    execute %(
      DROP FUNCTION IF EXISTS make_time();
    )
  end
end
