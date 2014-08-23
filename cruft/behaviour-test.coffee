request = require 'request'
get = require 'mout/object/get'
prop = require 'mout/function/prop'
fs = require 'fs'
_ = require 'highland'
ws = require 'ws'


it 'hej', (done)->
    opts =
      "method": "account_info"
      "params": [
        "account": "gEAZjCR4PUK8dyJAyjEry54pN2UqJKAB16"
      ]
    str = request
      method: 'POST'
      uri: 'https://live.stellar.org:9002'
      body: JSON.stringify opts

    hej = _()
    str.pipe(hej)
    hej.invoke('toString').each (buffer) ->
      parsed = JSON.parse(buffer)
      console.log("account_info", parsed)
      done()

toSimpleTransaction = (apiObject) ->
  from: apiObject.Account
  to: apiObject.Destination
  amount: apiObject.Amount


it 'heheheh', ->
  https = require('https');

  options = {
    host: 'api.stellar.org',
    port: 443,
    path: '/reverseFederation?domain=stellar.org&destination_address=gEAZjCR4PUK8dyJAyjEry54pN2UqJKAB16',
    method: 'GET'
  };

  req = https.request options, (res) ->
    if (res.statusCode is 200)
      res.on 'data', (d)  ->
        process.stdout.write(d);

  req.end();


it 'hej3', (done) ->
  this.timeout(200000);
  Remote = require('stellar-lib').Remote;

  remote = new Remote
  #  trace: true
    trusted: true
    servers: [{
      host:    'live.stellar.org'
      port:    9001
      secure:  true
    }]

  remote.connect ->
    console.log "connected"
    remote.on('transaction_all', transactionListener);
    remote.on('ledger_closed', ledgerListener);

  t = 0
  transactionListener = (payload) ->
    t++
    console.log("transaction amount is", payload.transaction.Amount)


  # reverse federation
  # https://api.stellar.org/reverseFederation?domain=stellar.org&destination_address=gEAZjCR4PUK8dyJAyjEry54pN2UqJKAB16
  # https seems to be required :(

  ledgerListener = (ledger_data) ->
    #console.log("ledger is", ledger_data)

it.only 'hej4', (done)->
  this.timeout(200000);
  WebSocket = require('ws')
  console.log("1")
  try
    ws = new WebSocket('ws://live.stellar.org:9001');
  catch error
    console.log 'error caught on construction', error
  console.log("2")
  try
    console.log("3")
    ws.on 'open',  ->
      console.log("oepned!")
      cb = ->
        console.log("cb", arguments)
      try
        ws.send(JSON.stringify({ "command" : "subscribe",   "accounts" : [ "asd7yasbysdgh" ] }), cb)
      catch error
        console.log("rror caught", error)

      ws.on 'message', (message) ->
        console.log 'message type', typeof(message)
        console.log('received: %s', message);

    ws.on 'error', (message) ->
      console.log("args", arguments)
      console.log('error: %s', message);
    console.log("4")
  catch error
    console.log 'error caught on open', error
it 'hej2', (done)->
    opts =
      "method": "account_tx"
      "params": [
        "account": "gEAZjCR4PUK8dyJAyjEry54pN2UqJKAB16"
      ]
    str = request
      method: 'POST'
      uri: 'https://live.stellar.org:9002'
      body: JSON.stringify opts

     _(str)
      .invoke('toString')
      .collect()
      .debounce(500)
      .invoke('join',[''])
      .map(JSON.parse)
      .each (response) ->
        transactions = get(response, 'result.transactions').map(prop('tx'))

        # Example transaction from stellar API
        # {
        #   "Account" : "gEAZjCR4PUK8dyJAyjEry54pN2UqJKAB16",
        #   "Amount" : "50000000",
        #   "Destination" : "gMYgpMLQTN3U7rPRJHLYFTLor1Tf4FGGPw",
        #   "Fee" : "12",
        #   "Flags" : 2147483648,
        #   "LastLedgerSequence" : 351055,
        #   "Sequence" : 17,
        #   "SigningPubKey" : "4A665A50B426C967F8651BED216A9F057D92614108BFD214FD713B5F62908FCA",
        #   "TransactionType" : "Payment",
        #   "TxnSignature" : "0420704BB59672100BA3BB7A535AD921D288972F88414B1517A13DA3AFE8A864FAF9E69FAA9F65260D988CB76653A3B70DE9BC29C180A96280E03DEE3C4D5701",
        #   "date" : 461493680,
        #   "hash" : "E22C74BE5E04BB52B6764DE7F31B13AE1C39557BA0B0980316AB512B20677727",
        #   "inLedger" : 351047,
        #   "ledger_index" : 351047
        #},

        simpleTransactions = transactions.map (tx) ->
          from: tx.Account
          to: tx.Destination
          amount: tx.Amount

        console.log("transactions", simpleTransactions)
        done()

      #.map(JSON.parse)
      #.map(prop('result'))
      #.map(prop('transactions'))
      #.map(prop('tx'))
      #.map(prop('amount'))
    #  .each (x) ->
      #  console.log("account_info", x)
