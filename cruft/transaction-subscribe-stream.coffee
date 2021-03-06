_ = require 'highland'

module.exports = (WebSocket, account) ->
  stream = _()
  ws = new WebSocket('ws://live.stellar.org:9001');
  ws.on 'open', ->
    payload = JSON.stringify
      "command" : "subscribe"
      "streams" :  [ "transactions" ]
      "accounts" : [ account ]
    ws.send payload, (error) ->
      stream.emit('error', error) if error
      ws.on 'message', (messageString) ->
        messageObject = JSON.parse messageString
        if messageObject.status is 'error'
          stream.emit('error', messageObject)
          return
        stream.write messageObject
  ws.on 'error', (error) ->
    stream.emit('error', error)
  stream
