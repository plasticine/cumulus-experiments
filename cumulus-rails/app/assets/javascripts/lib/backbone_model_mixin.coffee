# https://gist.github.com/ssorallen/7883081
@lib.BackboneModelMixin =
  componentDidMount: ->
    @_boundForceUpdate = @forceUpdate.bind(@, null)
    @getBackboneObjects().on("all", @_boundForceUpdate, @)

  componentWillUnmount: ->
    @getBackboneObjects().off("all", @_boundForceUpdate)

  getBackboneObjects: ->
    @props.collection || @props.model
