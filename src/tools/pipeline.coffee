through = require 'through'
pipeline = (streams...) ->
  through (incoming) ->
    streams.forEach (stream, i) ->
      next = streams[i + 1]
      stream.pipe next if next 
    streams.pop().on 'data', this.queue
    streams.shift().write incoming

module.exports = pipeline