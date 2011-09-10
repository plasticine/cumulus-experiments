def table_exists?(name)
  schema_name, table_name = Sequel::Model.db.send(:schema_and_table, name)
  Sequel::Model.db[:information_schema__tables].where(table_schema: schema_name, table_name: table_name).any?
end

def schema_exists?(name)
  Sequel::Model.db[:information_schema__schemata].where(schema_name: schema_name.to_s).any?
end
