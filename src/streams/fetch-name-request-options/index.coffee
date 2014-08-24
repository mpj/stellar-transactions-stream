through = require 'through'

module.exports = -> through (account) ->
  this.queue
    method: 'GET'
    uri: 'https://api.stellar.org/reverseFederation?domain=stellar.org&destination_address=' + account