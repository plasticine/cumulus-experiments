riak = require 'riak-js'

module.exports =
  class Client
    @instance: ->
      @_client ||= new Client

    constructor: ->
      @db = riak.getClient()
