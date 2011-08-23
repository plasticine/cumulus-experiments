uuid = require 'node-uuid'
Client = require '../client'

module.exports =
  class Fact
    create: (request, response) =>
      fact = request.body
      fact.id = uuid()
      fact.timestamp = Math.round(Date.now() / 1000.0)

      console.log fact

      # Store the fact in Riak.
      Client.instance().db.save "facts", fact.id, fact

      response.send "", {Location: "/facts/#{fact.id}"}, 201

    show: (request, response) =>
     Client.instance().db.get "facts", request.params.key, (error, fact) ->
        if !error
          response.send fact
        else if error && error.statusCode == 404
          response.send "Not Found", 404
        else
          throw error
