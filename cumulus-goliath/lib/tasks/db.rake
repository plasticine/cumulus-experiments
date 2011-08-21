require 'sequel'
require 'sequel/extensions/migration'

task :environment do
  Cumulus::Model.connect
end

namespace :db do
  desc "Migrate up"
  task :migrate => :environment do
    Sequel::Migrator.run(::Sequel::Model.db, "db/migrate")
  end
end
