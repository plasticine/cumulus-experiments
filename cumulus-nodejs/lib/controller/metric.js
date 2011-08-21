(function() {
  var Client, Metric, map, reduce;
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };
  Client = require('../client');
  map = function(value) {
    return value.values.map(function(value) {
      var fact, result, timestamp;
      fact = JSON.parse(value.data);
      timestamp = Math.floor(fact.timestamp / 60) * 60;
      result = {};
      result[timestamp] = {
        response_time: fact.response_time
      };
      return result;
    });
  };
  reduce = function(values) {
    var data, result, timestamp, value, _i, _len;
    result = {};
    for (_i = 0, _len = values.length; _i < _len; _i++) {
      value = values[_i];
      for (timestamp in value) {
        data = value[timestamp];
        if (timestamp in result) {
          result[timestamp] = {
            response_time: result[timestamp].response_time + data.response_time
          };
        } else {
          result[timestamp] = data;
        }
      }
    }
    return [result];
  };
  module.exports = Metric = (function() {
    function Metric() {
      this.show = __bind(this.show, this);
    }
    Metric.prototype.show = function(request, response) {
      var bucket;
      bucket = request.params.metric;
      return Client.instance().db.add(bucket).map(map).reduce(reduce).run(function(error, result) {
        return response.send(result);
      });
    };
    return Metric;
  })();
}).call(this);
