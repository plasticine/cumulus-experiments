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
      {type, from, to, group} = request.query
      Atom.aggregate type, from, to, group, (facts) ->
        response.send facts
