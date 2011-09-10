Sequel.default_timezone = :utc
Sequel.datetime_class = DateTime

Sequel::Model.plugin :timestamps, update_on_create: true

class Sequel::Model
  def save!
    save raise_on_save_failure: true
  end

  def update!(hash)
    set hash
    save raise_on_save_failure: true
  end
end
