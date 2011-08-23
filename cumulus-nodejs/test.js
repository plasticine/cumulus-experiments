{
  "inputs": {
    "module": "riak_search",
    "function": "mapred_search",
    "arg": ["facts", "type:page_view AND timestamp:[1314088600 TO 1314088660]"]
  },

  "query": [{
    "map": {
      "language": "javascript",
      "source": "
function(value, keyData, arg) {
  return value.values.map(function(value) {
    var result = {};
    var fact = JSON.parse(value.data);
    var timestamp = Math.floor(fact.timestamp / 60) * 60;
    var key = timestamp + '_' + fact.resource;
    result[key] = {
      timestamp: timestamp,
      resource: fact.resource,
      sum_response_time: fact.response_time,
      avg_response_time: fact.response_time,
      min_response_time: fact.response_time,
      max_response_time: fact.response_time,
      num_requests: 1
    };
    return result;
  });
}"
    }
  }, {
    "reduce": {
      "keep": true,
      "language": "javascript",
      "source": "
function(values, arg) {
  return [
    values.reduce(function(acc, value) {
      for (var key in value) {
        var fact = value[key];
        if (key in acc) {
          acc[key].sum_response_time = acc[key].sum_response_time + fact.sum_response_time;
          acc[key].avg_response_time = ((acc[key].avg_response_time * acc[key].num_requests) + (fact.avg_response_time * fact.num_requests)) / (acc[key].num_requests + fact.num_requests);
          acc[key].min_response_time = Math.min(acc[key].min_response_time, fact.min_response_time);
          acc[key].max_response_time = Math.max(acc[key].max_response_time, fact.max_response_time);
          acc[key].num_requests      = acc[key].num_requests + fact.num_requests;
        } else {
          acc[key] = fact;
        }
      }
      return acc;
    }, {})
  ];
}"
    }
  }
]}
