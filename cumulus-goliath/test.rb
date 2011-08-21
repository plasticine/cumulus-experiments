$: << 'lib'

require 'rubygems'
require 'bundler/setup'
require 'cumulus'

Cumulus::Model.connect

account=Cumulus::Model::Account.new(:name => "foo")
account.save!

token=Cumulus::Model::ApiToken.new(:account => account)
token.save!

puts account.inspect
puts token.inspect
