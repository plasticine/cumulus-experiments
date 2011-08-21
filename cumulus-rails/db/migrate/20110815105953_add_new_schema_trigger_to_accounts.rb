class AddNewSchemaTriggerToAccountsMigration < Sequel::Migration
  def up
    execute <<-SQL
      CREATE OR REPLACE FUNCTION public.create_account_schema()
      RETURNS trigger AS $$
        BEGIN
          EXECUTE 'CREATE SCHEMA account_' || NEW.id;
          RETURN NEW;
        END;
      $$ LANGUAGE plpgsql;
    SQL

    execute <<-SQL
      CREATE TRIGGER create_account_schema
      AFTER INSERT ON accounts
      FOR EACH ROW
      EXECUTE PROCEDURE public.create_account_schema();
    SQL

    execute <<-SQL
      CREATE OR REPLACE FUNCTION public.drop_account_schema()
      RETURNS trigger AS $$
        BEGIN
          EXECUTE 'DROP SCHEMA account_' || OLD.id;
          RETURN OLD;
        END;
      $$ LANGUAGE plpgsql;
    SQL

    execute <<-SQL
      CREATE TRIGGER drop_account_schema
      AFTER DELETE ON accounts
      FOR EACH ROW
      EXECUTE PROCEDURE public.drop_account_schema();
    SQL
  end

  def down
  end
end
