es = require 'event-stream'
request = require 'request'
module.exports = ->
  es.map (requestOptions, callback) ->
    request requestOptions, (error, response, body) -> callback error, body

  