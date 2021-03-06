connect  = require 'connect'
express  = require 'express'
resource = require 'express-resource'

AtomController = require './lib/controllers/atom'

app = express.createServer()

# TODO: authenticate the API token (X-API-Token).
authenticate = (request, response, next) ->
  account_id = request.headers["x-api-token"]
#   connect.utils.unauthorized response, "Authorization Required"
  request.current_account = "abc123"
  next()

app.configure ->
  app.use express.logger()
  app.use express.bodyParser()
  app.use authenticate

app.configure "development", ->
  app.use express.errorHandler(dumpExceptions: true, showStack: true)

app.configure "production", ->
  app.use express.errorHandler()

app.resource "atoms", new AtomController

app.listen 4000
console.log "Express server listening on port %d in %s mode", app.address().port, app.settings.env
