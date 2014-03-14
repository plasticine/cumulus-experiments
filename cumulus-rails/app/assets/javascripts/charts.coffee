#= require chart.min

SECOND_IN_MILLISECONDS = 1000

HOUR_IN_SECONDS = 3600
DAY_IN_SECONDS  = 86400

resizeElement = (el) ->
  el.get(0).width  = el.parent().width()
  el.get(0).height = el.parent().height()

calculateTimeRange = (resolution) ->
  delta = switch resolution
    when "week"
      28 * DAY_IN_SECONDS
    when "day"
      14 * DAY_IN_SECONDS
    when "hour"
      24 * HOUR_IN_SECONDS
    when "half_hour"
      12 * HOUR_IN_SECONDS
    when "quarter_hour", "sixth_hour"
      6 * HOUR_IN_SECONDS
    when "twelfth_hour"
      3 * HOUR_IN_SECONDS
    when "minute"
      2 * HOUR_IN_SECONDS
    else
      HOUR_IN_SECONDS

  to   = Math.round(Date.now() / SECOND_IN_MILLISECONDS)
  from = to - delta

  [from, to]

reload = ->
  canvas = $("#chart")
  metricId = canvas.data("metric-id")
  property = $("#property").val()
  resolution = $("#resolution").val()
  [from, to] = calculateTimeRange(resolution)
  url = "/metrics/#{metricId}/aggregate?property=#{property}&resolution=#{resolution}&from=#{from}&to=#{to}"

  $.getJSON url, (json) ->
    labels = json.map (d) -> d.timestamp

    min = json.map (d) -> d["min_#{property}"]
    avg = json.map (d) -> d["avg_#{property}"]
    max = json.map (d) -> d["max_#{property}"]

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

    redraw = ->
      resizeElement(canvas)
      new Chart(canvas.get(0).getContext("2d")).Line(data, options)

    $(window).resize(redraw)

    redraw()

$(document).ready ->
  $("#property").change -> reload()
  $("#resolution").change -> reload()

  reload()
