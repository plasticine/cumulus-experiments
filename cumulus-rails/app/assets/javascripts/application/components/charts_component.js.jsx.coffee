###* @jsx React.DOM ###

@app.components.ChartComponent = React.createClass
  mixins: [@lib.BackboneModelMixin]
  propTypes:
    model: React.PropTypes.instanceOf(app.models.ControlStateModel)

  handleResize: ->
    chart = @refs.chart.getDOMNode()
    chart.width  = $("#main").width()
    chart.height = $("#main").height()

  componentDidMount: ->
    $(window).bind 'resize', @handleResize
    @renderChart()

  componentDidUpdate: ->
    @renderChart()

  renderChart: ->
    $.getJSON @props.model.url(), (json) =>
      labels = json.map (d) -> d.timestamp

      min = json.map (d) => d["min_#{@props.model.property()}"]
      avg = json.map (d) => d["avg_#{@props.model.property()}"]
      max = json.map (d) => d["max_#{@props.model.property()}"]

      data =
        labels: labels
        datasets: [{
          fillColor:        "rgba(151, 187, 205, 0.5)"
          strokeColor:      "rgba(151, 187, 205, 1)"
          pointColor:       "rgba(151, 187, 205, 1)"
          pointStrokeColor: "#fff"
          data:             max
        }, {
          fillColor:        "rgba(0, 187, 205, 0.5)"
          strokeColor:      "rgba(0, 187, 205, 1)"
          pointColor:       "rgba(0, 187, 205, 1)"
          pointStrokeColor: "#fff"
          data:             avg
        }, {
          fillColor:        "rgba(220, 22, 22, 0.5)"
          strokeColor:      "rgba(220, 22, 22, 1)"
          pointColor:       "rgba(220, 22, 22, 1)"
          pointStrokeColor: "#fff"
          data:             min
        }]

      options =
        pointDot: false
        animationSteps: 10

      @handleResize()
      new Chart(@refs.chart.getDOMNode().getContext("2d")).Line(data, options)

  render: ->
    SpinnerComponent = app.components.SpinnerComponent

    `<div>
      <canvas id="chart" ref="chart"></canvas>
    </div>`
