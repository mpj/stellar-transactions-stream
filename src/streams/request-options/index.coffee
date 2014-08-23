
_ = require 'highland'

module.exports = _.through (input) ->
  input.map (account) ->
    method: 'POST'
    uri: 'https://live.stellar.org:9002'
    body: JSON.stringify
      "method": "account_tx"
      "params": [
        "account": account
      ]
