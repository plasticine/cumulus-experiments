###* @jsx React.DOM ###

@app.components.DashboardComponent = React.createClass
  propTypes:
    metricId: React.PropTypes.string.isRequired

  getDefaultProps: ->
    controlState: new app.models.ControlStateModel(metricId: @props.metricId)

  render: ->
    ControlsComponent = app.components.ControlsComponent
    ChartComponent = app.components.ChartComponent

    `<div>
      <ControlsComponent model={this.props.controlState} />
      <ChartComponent model={this.props.controlState} />
    </div>`
