uuid = require 'node-uuid'

Client = require '../client'

map_fun = (value, keyData, arg) ->
  return value.values.map (value) ->
    result = {}

    atom = JSON.parse(value.data)

    # Round the timestamp to the nearest minute.
    atom.timestamp = Math.floor(atom.timestamp / 60) * 60

    group = ["timestamp"].concat arg.group
    grain = group.map((value) -> atom[value]).join("_")

    result[grain] = {
      timestamp:         atom.timestamp,
      resource:          atom.resource,
      sum_response_time: atom.response_time,
      avg_response_time: atom.response_time,
      min_response_time: atom.response_time,
      max_response_time: atom.response_time,
      count:             1
    }

    result

reduce_fun = (values) ->
  return [
    values.reduce (acc, value) ->
      for grain, atom of value
        if grain of acc
          acc[grain].sum_response_time = acc[grain].sum_response_time + atom.sum_response_time
          acc[grain].avg_response_time = ((acc[grain].avg_response_time * acc[grain].count) + (atom.avg_response_time * atom.count)) / (acc[grain].count + atom.count)
          acc[grain].min_response_time = Math.min(acc[grain].min_response_time, atom.min_response_time)
          acc[grain].max_response_time = Math.max(acc[grain].max_response_time, atom.max_response_time)
          acc[grain].count             = acc[grain].count + atom.count
        else
          acc[grain] = atom
      acc
  ]

module.exports =
  class Atom
    @find: (id, callback) ->
      Client.instance().db.get "atoms", id, (error, result) ->
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

    @aggregate: (type, from, to, group, callback) ->
      group = group.split ","

      Client.instance().db
        .addSearch("atoms", "type:#{type} AND timestamp:[#{from} TO #{to}]")
        .map(map_fun, group: group)
        .reduce(reduce_fun)
        .run (error, results) ->
#           results = (value for key, value of results[0])
          callback results

    constructor: (properties) ->
      this.setProperties properties
      @id = uuid()
      @timestamp = Math.round(Date.now() / 1000.0)

    save: ->
      Client.instance().db.save "atoms", @id, this

    setProperties: (properties) ->
      for key, value of properties
        this[key] = value
