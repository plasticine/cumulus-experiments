require 'digest/md5'

module Cumulus
  module Model
    class ApiToken
      include ::Ripple::Document

      property :value, String, :presence => true, :default => proc { Digest::MD5.new.to_s }
      attr_protected :value
      key_on :value

      property :account_key, String, :presence => true
      one :account, :class => Account, :using => :stored_key
    end
  end
end
