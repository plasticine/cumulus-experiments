unless defined?(CUMULUS_ENV)
  CUMULUS_ENV = ENV["CUMULUS_ENV"] || "development"
end

require 'active_support/core_ext/string'

module Cumulus
  class << self
    def env
      @env ||= ActiveSupport::StringInquirer.new(CUMULUS_ENV)
    end

    def env=(environment)
      @env = ActiveSupport::StringInquirer.new(environment)
    end

    def root
      @root ||= File.expand_path('../../', __FILE__)
    end
  end
end

require 'cumulus/model'
