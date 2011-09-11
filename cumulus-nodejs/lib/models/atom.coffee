uuid = require 'node-uuid'

Client = require '../client'

module.exports =
  class Atom
    # TODO: infer this name from the class using the lingo lib.
    @bucket: "atoms"

    @mapFunction: (value, keyData, args) ->
      return value.values.map (value) ->
        result = {}

        atom = JSON.parse(value.data)

        # Round the timestamp to the nearest minute.
        atom.timestamp = Math.floor(atom.timestamp / 60) * 60

        # Timestamp is always a group.
        groups = ["timestamp"].concat args.groups

        # Make a grain key by joining the groups.
        grain = groups.map((group) -> atom[group]).join("_")

        result[grain] =
          sum:   atom[args.property]
          avg:   atom[args.property]
          min:   atom[args.property]
          max:   atom[args.property]
          count: 1

        groups.forEach (group) ->
          result[grain][group] = atom[group]

        result

    @reduceFunction: (values) ->
      return [
        values.reduce ((acc, value) ->
          for grain, atom of value
            if grain of acc
              acc[grain].sum   = acc[grain].sum + atom.sum
              acc[grain].avg   = ((acc[grain].avg * acc[grain].count) + (atom.avg * atom.count)) / (acc[grain].count + atom.count)
              acc[grain].min   = Math.min(acc[grain].min, atom.min)
              acc[grain].max   = Math.max(acc[grain].max, atom.max)
              acc[grain].count = acc[grain].count + atom.count
            else
              acc[grain] = atom
          acc
        ), {}
      ]

    @generateUUID: -> uuid()

    @currentTimestamp: -> Math.round(Date.now() / 1000.0)

    @find: (id, callback) ->
      Client.instance().db.get Atom.bucket, id, (error, result) ->
        if !error
          callback result
        else if error && error.statusCode == 404
          callback null
        else
          throw error

    @create: (properties) ->
      atom = new Atom properties
      atom.save()
      atom

    @aggregate: (type, from, to, property, group, callback) ->
      groups = group.split ","

      Client.instance().db
        .addSearch(Atom.bucket, "type:#{type} AND timestamp:[#{from} TO #{to}]")
        .map(Atom.mapFunction, property: property, groups: groups)
        .reduce(Atom.reduceFunction)
        .run (error, results) ->
          results = (value for key, value of results[0])
          callback results

    constructor: (properties) ->
      this._setProperties properties
      @id        = Atom.generateUUID()
      @timestamp = Atom.currentTimestamp()

    save: -> Client.instance().db.save "atoms", @id, this

    _setProperties: (properties) ->
      for key, value of properties
        this[key] = value
