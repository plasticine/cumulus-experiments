#= require chart.min

SECOND_IN_MILLISECONDS = 1000
HOUR_IN_SECONDS        = 3600

resizeElement = (el) ->
  el.get(0).width  = el.parent().width()
  el.get(0).height = el.parent().height()

$(document).ready ->
  canvas = $("#chart")

  to   = Math.round(Date.now() / SECOND_IN_MILLISECONDS)
  from = to - (12 * HOUR_IN_SECONDS)

  metricId = canvas.data("metric-id")

  url = "/metrics/#{metricId}/aggregate?resolution=quarter_hour&from=#{from}&to=#{to}"

  $.getJSON url, (json) ->
    labels             = json.map (d) -> d.timestamp
    min_response_times = json.map (d) -> d.min_response_time
    avg_response_times = json.map (d) -> d.avg_response_time
    max_response_times = json.map (d) -> d.max_response_time

    data =
      labels: labels
      datasets: [{
        fillColor:        "rgba(151, 187, 205, 0.5)"
        strokeColor:      "rgba(151, 187, 205, 1)"
        pointColor:       "rgba(151, 187, 205, 1)"
        pointStrokeColor: "#fff"
        data:             max_response_times
      }, {
        fillColor:        "rgba(0, 187, 205, 0.5)"
        strokeColor:      "rgba(0, 187, 205, 1)"
        pointColor:       "rgba(0, 187, 205, 1)"
        pointStrokeColor: "#fff"
        data:             avg_response_times
      }, {
        fillColor:        "rgba(220, 22, 22, 0.5)"
        strokeColor:      "rgba(220, 22, 22, 1)"
        pointColor:       "rgba(220, 22, 22, 1)"
        pointStrokeColor: "#fff"
        data:             min_response_times
      }]

    options =
      pointDot:  false
      animation: false

    redraw = ->
      resizeElement(canvas)
      new Chart(canvas.get(0).getContext("2d")).Line(data, options)

    $(window).resize(redraw)

    redraw()
