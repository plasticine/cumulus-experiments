$(document).ready ->
  Highcharts.setOptions
    global:
      useUTC: false

  chartDidLoad = ->
    metric_id = $(this.container).parent().attr("data-metric-id")
    addSeries(this, metric_id, "avg")
#     addSeries(this, metric_id, "max")
#     addSeries(this, metric_id, "min")

  addSeries = (chart, metric_id, aggregation) ->
    callback = (data) ->
      data = data.map (datum) -> [Date.parse(datum.timestamp), Math.round(datum.value * 100) / 100]
      chart.addSeries(data: data, name: aggregation)
#       chart.hideLoading()
    to = Math.round(Date.now() / 1000)
    from = to - 3600
    url = "/metrics/#{metric_id}/aggregate?resolution=twelfth_hour&function=#{aggregation}&from=#{from}&to=#{to}"
#     chart.showLoading()
    $.get url, callback, "json"

  $(".chart").each (index, element) ->
    chart = new Highcharts.Chart
      chart:
        renderTo: "container"
        events:
          load: chartDidLoad

      xAxis:
        type: "datetime"

      yAxis:
        title: null
