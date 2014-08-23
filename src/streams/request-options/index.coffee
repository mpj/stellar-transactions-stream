es = require 'event-stream'

module.exports = -> 
  es.map (account, callback) -> 
    callback(null,
      method: 'POST'
      uri: 'https://live.stellar.org:9002'
      body: JSON.stringify
        "method": "account_tx"
        "params": [
          "account": account
        ]
    )
