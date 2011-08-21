Client = require '../client'

module.exports =
  class Fact
    create: (request, response) =>
      fact = request.body
      fact.timestamp = Math.round(Date.now() / 1000.0)

      console.log fact

      # TODO: journal the fact.

      # TODO: ensure the bucket allows multiple items (allow_mult).
      # curl -X PUT -H "Content-Type: application/json" -d '{"props":{"allow_mult":true}}' http://127.0.0.1:8098/riak/my_bucket

      # Store the fact in Riak.
      Client.instance().db.save "test", fact.timestamp, fact

      response.send "", {Location: "/facts/#{fact.timestamp}"}, 201

    show: (request, response) =>
     Client.instance().db.get "test", request.params.key, (error, fact) ->
        if !error
          response.send fact
        else if error && error.statusCode == 404
          response.send "Not Found", 404
        else
          throw error
