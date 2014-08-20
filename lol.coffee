request = require 'request'
prop = require 'mout/function/prop'
_ = require 'highland'
websocket = require('websocket-stream')
JSONStream = require 'JSONStream'
https = require 'https'
through = require 'through'
prettyjson = require 'prettyjson'
fs = require 'fs'


clearCapture -> fs.unlink('capture.js')

capture = (title) ->
  _.pipeline (s) ->
    s.map (val) ->
      console.log ''
      console.log '[CAPTURED] ' + title + ":"
      console.log prettyjson.render val
      console.log ''

      fs.appendFileSync('capture.js', '// [CAPTURED] ' + title + '\n');
      fs.appendFileSync('capture.js', JSON.stringify(val, null,2))
      fs.appendFileSync('capture.js', "\n\n")
      val



it.only 'only', ->

  currentTransactions = (account) ->
    currentTransactionRequest = request
      method: 'POST'
      uri: 'https://live.stellar.org:9002'
      body: JSON.stringify
        "method": "account_tx"
        "params": [
          "account": account
        ]
    jsonResponseStream = currentTransactionRequest.pipe JSONStream.parse()

    extractTransactions = (jsonResponse) ->
      jsonResponse.result.transactions
        .map(prop('tx'))
        .reverse()

    _(jsonResponseStream).map(extractTransactions).flatten()

  futureTransactions = (account) ->
    out = _()
    ws = websocket 'ws://live.stellar.org:9001'
    ws.on 'open', ->
      ws.write JSON.stringify
        "command" : "subscribe",
        "accounts" : [ account ]
      _(ws.pipe(JSONStream.parse()))
        .map(prop 'transaction')
        .pipe(out)
    out



  fetchName = (account) ->
    options =
      method: 'GET'
      host: 'api.stellar.org'
      path: '/reverseFederation?domain=stellar.org&destination_address=' + account
      port: 443
    req = https.request options, (res) -> res.pipe jsonStream
    req.end()
    jsonStream = JSONStream.parse()
    _(jsonStream).map (response) ->
      if response.error is 'noSuchUser'
        return 'Unknown'
      response.federation_json.destination

  federate = _.pipeline (transactionS) ->

    transactionS.flatMap (transaction) ->
      _([
        fetchName(transaction.Account),
        fetchName(transaction.Destination)
      ]).parallel(2).collect().map((names) ->
        transaction.AccountName = names[0]
        transaction.DestinationName = names[1]
        transaction
      )

  simplify = _.pipeline (txS) ->
    txS
      .filter (tx) ->
        tx.TransactionType is 'Payment'
      .map (tx) ->
        date: tx.date
        from: tx.AccountName
        to: tx.DestinationName
        amount: tx.Amount



  #fetchName('gEAZjCR4PUK8dyJAyjEry54pN2UqJKAB16')
    #.on('data',
      #console.log.bind(null, 'sum acc'))

  account = "gEAZjCR4PUK8dyJAyjEry54pN2UqJKAB16" # mpj
  #account = "gDSSa75HPagWcvQmwH7D51dT5DPmvsKL4q" # StellarFoundation
  transactions = currentTransactions(account)
    .pipe(federate)
    .pipe(capture('post-federate'))
    .pipe(simplify)
    .pipe(logger('post-simplfy'))
    .on 'data', ->
