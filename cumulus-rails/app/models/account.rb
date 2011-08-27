require 'digest/sha1'

class Account < Sequel::Model
  one_to_many :metrics

  def validate
    super
    validates_presence [:name, :api_key]
  end

  def before_validation
    self.api_key = Digest::SHA1.new.to_s
    super
  end

  def after_create
    super
    db.execute "CREATE SCHEMA account_#{id}"
  end

  def before_destroy
    db.execute "DROP SCHEMA account_#{id}"
    super
  end
end
