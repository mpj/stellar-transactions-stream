spec = require './spec.coffee'
_ = require 'highland'
request = require 'request'
JSONStream = require 'JSONStream'
isFunction = require 'mout/lang/isFunction'

jsonRequest = -> 
  _.pipeline (s) ->
    s.flatMap (opts) -> 
      output = _()
      request(opts).pipe output
      output
    .through JSONStream.parse()


requestOptions = ->
  _.pipeline (s) ->
    s.map (account) ->
      method: 'POST'
      uri: 'https://live.stellar.org:9002'
      body: JSON.stringify
        "method": "account_tx"
        "params": [
          "account": account
        ]
      
spec(requestOptions)
  .describe 'requestOptions generates request options '
  .given 'gEAZjCR4PUK8dyJAyjEry54pN2UqJKAB16'
  .yields
    "method": "POST",
    "uri": "https://live.stellar.org:9002",
    "body": "{\"method\":\"account_tx\",\"params\":[{\"account\":\"gEAZjCR4PUK8dyJAyjEry54pN2UqJKAB16\"}]}"

  .describe 'requestOptions generates request options (alternate)'
  .given 'gDSSa75HPagWcvQmwH7D51dT5DPmvsKL4q'
  .yields
    "method": "POST",
    "uri": "https://live.stellar.org:9002",
    "body": "{\"method\":\"account_tx\",\"params\":[{\"account\":\"gDSSa75HPagWcvQmwH7D51dT5DPmvsKL4q\"}]}"


simplifyTransactions = ->
  _.pipeline (s) ->
    s.map (result) -> 
      result.result.transactions
        .map (x) -> 
          from:   
            address: x.tx.Account
          to:     
            address: x.tx.Destination
          amount: x.tx.Amount
          date:   x.tx.date
      
      
spec(simplifyTransactions)
  .describe 'Simplifies output'
  .given
    "result": {
      "account": "gEAZjCR4PUK8dyJAyjEry54pN2UqJKAB16",
      "ledger_index_max": 452270,
      "ledger_index_min": 0,
      "status": "success",
      "transactions": [
        {
          "meta": {
            "AffectedNodes": [
              {
                "ModifiedNode": {
                  "FinalFields": {
                    "Account": "g3J3rBZk5frd5TWB58sHECMFDw3mPB4c7o",
                    "Balance": "34999964",
                    "Flags": 0,
                    "InflationDest": "g4eRqgZfzfj3132y17iaf2fp6HQj1gofjt",
                    "OwnerCount": 0,
                    "Sequence": 4
                  },
                  "LedgerEntryType": "AccountRoot",
                  "LedgerIndex": "230FD9F6D52453B1A82409717C4547CAC5F9A65E3672A9C399FD34AB048DD67D",
                  "PreviousFields": {
                    "Balance": "33999964"
                  },
                  "PreviousTxnID": "10F35FAAC657B7413E4DC28BB1E0E6CBE8F8DB46E8768E5BE78D87415C938778",
                  "PreviousTxnLgrSeq": 396420
                }
              },
              {
                "ModifiedNode": {
                  "FinalFields": {
                    "Account": "gEAZjCR4PUK8dyJAyjEry54pN2UqJKAB16",
                    "Balance": "112706874149",
                    "Flags": 0,
                    "InflationDest": "gaj43wzt5XD8fz6JfbnaVQsewLtdfU5cFK",
                    "OwnerCount": 0,
                    "Sequence": 22
                  },
                  "LedgerEntryType": "AccountRoot",
                  "LedgerIndex": "82464B75E5E13BF2C3F80654662959AC37169EDD7269162FD8AD3AF7AA2D78FF",
                  "PreviousFields": {
                    "Balance": "112707874161",
                    "Sequence": 21
                  },
                  "PreviousTxnID": "10F35FAAC657B7413E4DC28BB1E0E6CBE8F8DB46E8768E5BE78D87415C938778",
                  "PreviousTxnLgrSeq": 396420
                }
              }
            ],
            "TransactionIndex": 2,
            "TransactionResult": "tesSUCCESS"
          },
          "tx": {
            "Account": "gEAZjCR4PUK8dyJAyjEry54pN2UqJKAB16",
            "Amount": "1000000",
            "Destination": "g3J3rBZk5frd5TWB58sHECMFDw3mPB4c7o",
            "TransactionType": "Payment",
            "date": 461710030
          },
          "validated": true
        }
      ]
    }
  .yields [
    {
      "from": 
        address: "gEAZjCR4PUK8dyJAyjEry54pN2UqJKAB16"
      "to": 
        address: "g3J3rBZk5frd5TWB58sHECMFDw3mPB4c7o"
      "amount": "1000000",
      "date": 461710030
    }
  ]
  
  
    
spec( ->
    _.pipeline( 
      requestOptions(),
      jsonRequest(),
      simplifyTransactions()
    )
  ).describe 'end to end simplifyTransactions'
  .given 'gEAZjCR4PUK8dyJAyjEry54pN2UqJKAB16'


simpleTransform = (mapper) ->
  -> 
    _.pipeline (s) ->
      s.flatMap (value) -> 
        mapperResult = mapper(value)
        if isFunction(value.pipe)
          mapperResult
        else
          _([mapperResult])

federationRequestOptionsCreator = simpleTransform (account) ->
  method: 'GET'
  host: 'api.stellar.org'
  path: '/reverseFederation?domain=stellar.org&destination_address=' + account
  port: 443
  
console.log 'hej', federationRequestOptionsCreator

spec(federationRequestOptionsCreator)
  .describe('federationRequestOptionsCreator')
  .given('gEAZjCR4PUK8dyJAyjEry54pN2UqJKAB16')
  .yields {
    "method": "GET",
    "host": "api.stellar.org",
    "path": "/reverseFederation?domain=stellar.org&destination_address=gEAZjCR4PUK8dyJAyjEry54pN2UqJKAB16",
    "port": 443
  }


spec( ->
    _.pipeline( 
      federationRequestOptionsCreator(),
      jsonRequest()
    )
  ).describe 'end to end simplifyTransactions'
  .given 'gEAZjCR4PUK8dyJAyjEry54pN2UqJKAB16'
  .inspect()