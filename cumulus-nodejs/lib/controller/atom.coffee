Atom   = require '../model/atom'
Client = require '../client'

module.exports =
  class AtomController
    create: (request, response) ->
      atom = Atom.create request.body
      response.send "", {Location: "/atoms/#{atom.id}"}, 201

    show: (request, response) ->
      Atom.find request.params.atom, (atom) ->
        if atom?
          response.send atom
        else
          response.send "Not Found", 404

    index: (request, response) ->
      Atom.aggregate request.query.type, request.query.from, request.query.to, (facts) ->
        response.send facts
