Sequel.default_timezone = :utc

Sequel::Model.db.extension :pg_array
Sequel::Model.plugin :timestamps, update_on_create: true
Sequel::Model.plugin :validation_helpers

module Sequel
  class Model
    def save!
      save(raise_on_save_failure: true)
    end

    def update!(hash)
      set(hash)
      save(raise_on_save_failure: true)
    end
  end
end
