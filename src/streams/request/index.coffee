through = require 'through'
request = require 'request'
module.exports = ->
  through (requestOptions) ->
    self = this
    request requestOptions, (error, response, body) -> 
      if error
        throw error
      self.queue body

  