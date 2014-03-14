@app.models.ControlStateModel = class ControlStateModel extends Backbone.Model
  defaults:
    property: 'response_time'
    resolution: 'week'
    metricId: null

  SECOND_IN_MILLISECONDS: 1000
  HOUR_IN_SECONDS: 3600
  DAY_IN_SECONDS : 86400

  property: ->
    @get('property')

  resolution: ->
    @get('resolution')

  url: ->
    [from, to] = @calculateTimeRange(@get('resolution'))
    "/metrics/#{@get('metricId')}/aggregate?property=#{@get('property')}&resolution=#{@get('resolution')}&from=#{from}&to=#{to}"

  calculateTimeRange: (resolution) ->
    delta = switch resolution
      when "week"
        28 * @DAY_IN_SECONDS
      when "day"
        14 * @DAY_IN_SECONDS
      when "hour"
        24 * @HOUR_IN_SECONDS
      when "half_hour"
        12 * @HOUR_IN_SECONDS
      when "quarter_hour", "sixth_hour"
        6 * @HOUR_IN_SECONDS
      when "twelfth_hour"
        3 * @HOUR_IN_SECONDS
      when "minute"
        2 * @HOUR_IN_SECONDS
      else
        @HOUR_IN_SECONDS

    to   = Math.round(Date.now() / @SECOND_IN_MILLISECONDS)
    from = to - delta

    [from, to]
