_ = require 'highland'

module.exports = (WebSocket, account) ->
  stream = _()
  ws = new WebSocket('ws://live.stellar.org:9001');
  ws.on 'open', ->
    payload = JSON.stringify
      "command" : "subscribe"
      "accounts" : [ account ]
    ws.send payload, (error) ->
      stream.emit('error', error) if error
      ws.on 'message', (messageString) ->
        messageObject = JSON.parse messageString
        if messageObject.status is 'error'
          stream.emit('error', messageObject)
          return
        stream.write
          from: messageObject.transaction.Account
          to: messageObject.transaction.Destination
          amount: parseInt(messageObject.transaction.Amount)
          date: messageObject.transaction.date
  ws.on 'error', (error) ->
    stream.emit('error', error)
  stream
