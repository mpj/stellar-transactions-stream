through = require 'through'

module.exports = -> 
  through (account) -> this.queue(
    method: 'POST'
    uri: 'https://live.stellar.org:9002'
    body: JSON.stringify
      "method": "account_tx"
      "params": [
        "account": account
      ]
  )
