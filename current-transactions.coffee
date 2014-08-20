request = require 'request'
_ = require 'highland'
JSONStream = require 'JSONStream'
prop = require 'mout/function/prop'

module.exports = () ->
  _.pipeline (s) ->
    s.flatMap (account) ->

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
