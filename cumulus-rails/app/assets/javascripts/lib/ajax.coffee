@lib.ajax = (url, options = {}) ->
  options = _.defaults(options, method: 'GET')
  deferred = Q.defer()

  request = new XMLHttpRequest
  request.open(options.method, url, true)
  request.onload = ->
    if @status >= 200 and @status < 400
      deferred.resolve(status: @status, data: @response)
    else
      deferred.reject(@)
  request.onerror = ->
    deferred.reject(@)
  request.send()
  deferred.promise
