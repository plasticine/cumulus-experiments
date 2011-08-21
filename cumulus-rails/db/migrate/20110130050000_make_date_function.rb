class MakeDateFunctionMigration < Sequel::Migration
  def up
    execute %(
      CREATE OR REPLACE FUNCTION make_date(anyelement, anyelement, anyelement)
      RETURNS date AS $$
        SELECT ($1 || '-' || $2 || '-' || $3)::date;
      $$ LANGUAGE SQL;
    )
  end

  def down
    execute %(
      DROP FUNCTION IF EXISTS make_date();
    )
  end
end
