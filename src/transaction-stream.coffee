_ = require 'highland'

module.exports = (WebSocket, account) ->
  stream = _()
  ws = new WebSocket('ws://live.stellar.org:9001');
  ws.on 'open', ->
    ws.send JSON.stringify
      "command" : "subscribe"
      "accounts" : [ account ]
    ws.on 'message', (messageString) ->
      messageObject = JSON.parse messageString
      stream.write
        from: messageObject.transaction.Account
        to: messageObject.transaction.Destination
        amount: parseInt(messageObject.transaction.Amount)
        date: messageObject.transaction.date

  stream
