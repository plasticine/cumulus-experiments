module Cumulus
  module Model
    class Fact
      include ::Ripple::Document

      property :timestamp,  Time,   :presence => true, :default => proc { Time.now }
      property :name,       String, :presence => true
      property :properties, Hash
    end
  end
end
