assert = require "assert"
sinon  = require "sinon"
vows   = require "vows"

Atom   = require "../../lib/models/atom"
Client = require "../../lib/client"

values = ->
  values: [
    {data: """{"type":"page_view","response_time":123,"resource":"index","id":"58756817-7b05-4c1b-9351-9047fad6d969","timestamp":1315712941}"""}
    {data: """{"type":"page_view","response_time":234,"resource":"index","id":"58756817-7b05-4c1b-9351-9047fad6d969","timestamp":1315712999}"""}
    {data: """{"type":"page_view","response_time":345,"resource":"index","id":"66e15fa2-96ed-4c44-aede-24462ce4812b","timestamp":1315713059}"""}
  ]

mappings = ->
  [{
    "1315712940_index":
      timestamp: 1315712940
      resource:  'index'
      sum:       123
      avg:       123
      min:       123
      max:       123
      count:     1
  }, {
    "1315712940_index":
      timestamp: 1315712940
      resource:  'index'
      sum:       234
      avg:       234
      min:       234
      max:       234
      count:     1
  }, {
    "1315713000_index":
      timestamp: 1315713000
      resource:  'index'
      sum:       345
      avg:       345
      min:       345
      max:       345
      count:     1
  }]

reductions = ->
  [{
    "1315712940_index":
      timestamp: 1315712940
      resource:  'index'
      sum:       357
      avg:       178.5
      min:       123
      max:       234
      count:     2

    "1315713000_index":
      timestamp: 1315713000
      resource:  'index'
      sum:       345
      avg:       345
      min:       345
      max:       345
      count:     1
  }]

vows
  .describe("Atom")

  .addBatch
    "instance":
      topic: ->
        sinon
          .stub(Atom, "generateUUID")
          .returns("655cdd53-6532-45bc-8835-3b79155ec153")

        sinon
          .stub(Atom, "currentTimestamp")
          .returns(1315709729)

        @stub = sinon.stub(Client.instance().db, "save")

        new Atom foo: 1, bar: 2

      "should set the ID": (atom) ->
        assert.equal atom.id, "655cdd53-6532-45bc-8835-3b79155ec153"

      "should set the timestamp": (atom) ->
        assert.equal atom.timestamp, 1315709729

      "should set the properties": (atom) ->
        assert.equal atom.foo, 1
        assert.equal atom.bar, 2

      "#save":
        topic: (atom) ->
          atom.save()
          atom

        "should save the model": (atom) ->
          sinon.assert.calledWith @stub, "atoms", atom.id, atom

    ".mapFunction":
      "with no values":
        topic: -> Atom.mapFunction {values: []}, null, {}

        "should return an empty array": (result) ->
          assert.deepEqual result, []

      "with values":
        topic: ->
          args = {property: "response_time", groups: "resource"}

          Atom.mapFunction values(), null, args

        "should return the expected results": (results) ->
          assert.deepEqual results, mappings()

    ".reduceFunction":
      "with no values":
        topic: -> Atom.reduceFunction []

        "should return a single empty hash": (result) ->
          assert.deepEqual result, [{}]

      "with values":
        topic: -> Atom.reduceFunction mappings()

        "should return the expected results": (results) ->
          assert.deepEqual results, reductions()

  .export(module)
