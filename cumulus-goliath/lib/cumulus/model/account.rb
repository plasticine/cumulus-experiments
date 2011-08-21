module Cumulus
  module Model
    class Account
      include ::Ripple::Document

      property :name, String, :presence => true
    end
  end
end
