Client = require '../client'

map = (value) ->
  value.values.map((value) ->
    fact = JSON.parse(value.data)
    timestamp = Math.floor(fact.timestamp / 60) * 60 # nearest minute
    result = {}
    result[timestamp] = {response_time: fact.response_time}
    result
  )

reduce = (values) ->
  result = {}
  for value in values
    for timestamp, data of value
      if (timestamp of result)
        result[timestamp] = {response_time: result[timestamp].response_time + data.response_time}
      else
        result[timestamp] = data
  [result]

module.exports =
  class Metric
    show: (request, response) =>
      bucket = request.params.metric

      Client.instance().db
#       .add(bucket: bucket, key_filters: [["between", "1312880100", "1312880160"]])
      .add(bucket)
      .map(map)
      .reduce(reduce)
      .run((error, result) -> response.send result)
