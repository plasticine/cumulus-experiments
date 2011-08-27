class AddNewMetricTriggerToMetricsMigration < Sequel::Migration
  def up
    execute <<-SQL
    CREATE OR REPLACE FUNCTION array_to_columns(a anyarray)
    RETURNS text AS $$
      DECLARE
        result text;
      BEGIN
        a := array_append(a, '');
        result := '"' || array_to_string(a, '" float4, "');
        RETURN trim(trailing '"' from result);
      END;
    $$ LANGUAGE plpgsql;
    SQL

    execute <<-SQL
      CREATE OR REPLACE FUNCTION public.create_metric_table()
      RETURNS trigger AS $$
        BEGIN
          EXECUTE 'CREATE TABLE account_' || NEW.account_id || '.metric_' || NEW.id || ' (
            "timestamp" timestamp(0),' || array_to_columns(NEW.grains) || '
            "value" float4,
            CONSTRAINT "metric_' || NEW.id || 'pkey" PRIMARY KEY ("timestamp") NOT DEFERRABLE INITIALLY IMMEDIATE
          )';
          EXECUTE 'CREATE INDEX metric_' || NEW.id || '_date_index ON account_' || NEW.account_id || '.metric_' || NEW.id || ' ((timestamp::date))';
          EXECUTE 'CREATE INDEX metric_' || NEW.id || '_time_index ON account_' || NEW.account_id || '.metric_' || NEW.id || ' ((timestamp::time))';
          RETURN NEW;
        END;
      $$ LANGUAGE plpgsql;
    SQL

    execute <<-SQL
      CREATE TRIGGER create_metric_table
      AFTER INSERT ON metrics
      FOR EACH ROW
      EXECUTE PROCEDURE public.create_metric_table();
    SQL

    execute <<-SQL
      CREATE OR REPLACE FUNCTION public.drop_metric_table()
      RETURNS trigger AS $$
        BEGIN
          EXECUTE 'DROP TABLE account_' || OLD.account_id || '.metric_' || OLD.id;
          RETURN OLD;
        END;
      $$ LANGUAGE plpgsql;
    SQL

    execute <<-SQL
      CREATE TRIGGER drop_metric_table
      AFTER DELETE ON metrics
      FOR EACH ROW
      EXECUTE PROCEDURE public.drop_metric_table();
    SQL
  end

  def down
  end
end
