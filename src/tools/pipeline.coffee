through = require 'through'
pipeline = (streams...) ->
  api =
    through (incoming) ->
      
      loggedChain = []
      streams.forEach (stream) ->
        loggedChain.push logger()
        loggedChain.push stream
      streams = loggedChain
      streams.forEach (stream, i) ->
        next = streams[i + 1]
        stream.pipe next if next 
      last = streams[streams.length-1]
      last.on 'data', this.queue
      streams[0].write incoming
  
  logger = -> through (passed) ->
    api.emit 'passed', passed
    this.queue passed
  
  api

module.exports = pipeline