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
end
