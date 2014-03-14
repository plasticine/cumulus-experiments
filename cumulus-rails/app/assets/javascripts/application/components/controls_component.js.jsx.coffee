###* @jsx React.DOM ###

@app.components.ControlsComponent = React.createClass
  mixins: [@lib.BackboneModelMixin]
  propTypes:
    model: React.PropTypes.instanceOf(app.models.ControlStateModel)

  resolutionOptions:
    week: "week"
    day: "day"
    hour: "hour"
    half_hour: "30 minutes"
    quarter_hour: "15 minutes"
    sixth_hour: "10 minutes"
    twelfth_hour: "5 minutes"
    minute: "minute"

  propertyOptions:
    response_time: "Response Time"
    render_time: "Render Time"

  handlePropertyChange: (event) ->
    @props.model.set(property: event.target.value)

  handleResolutionChange: (event) ->
    @props.model.set(resolution: event.target.value)

  render: ->
    `<header id="controls">
      Property:
      <select ref="property" onChange={this.handlePropertyChange} value={this.props.model.property()}>
        {this.optionsNodes(this.propertyOptions)}
      </select>

      Resolution:
      <select ref="resolution" onChange={this.handleResolutionChange} value={this.props.model.resolution()}>
        {this.optionsNodes(this.resolutionOptions)}
      </select>
    </header>`

  optionsNodes: (options) ->
    for value, name of options
      `<option key={value} value={value}>{name}</option>`

