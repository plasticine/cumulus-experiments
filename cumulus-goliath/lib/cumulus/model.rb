require 'sequel'
require 'ripple'

module Cumulus
  module Model
    class << self
      def database_config
        @database_config ||= YAML.load(File.read(File.join(Cumulus.root, 'config', 'database.yml')))
      end

      def connect
        Sequel.connect(database_config[Cumulus.env])
      end
    end

    autoload :Account,  'cumulus/model/account'
    autoload :ApiToken, 'cumulus/model/api_token'
    autoload :Fact,     'cumulus/model/fact'
  end
end
