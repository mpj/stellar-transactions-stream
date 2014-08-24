account = 'gEAZjCR4PUK8dyJAyjEry54pN2UqJKAB16'
spec = require './tools/stream-spec'
pipeline = require './tools/pipeline'
JSONStream = require 'JSONStream'


prop = require 'mout/function/prop'

request = require './streams/request'
requestOptions = require './streams/request-options'
simpleTransactions = require './streams/simple-transactions'


through = require 'through'

fetchNameRequestOptions = -> through (account) ->

  this.queue
    method: 'GET'
    uri: 'https://api.stellar.org/reverseFederation?domain=stellar.org&destination_address=' + account


federationRequest = -> pipeline fetchNameRequestOptions(), request(),
            JSONStream.parse()

                         
module.exports = spec(federationRequest)
  .case()
  .given 'gEAZjCR4PUK8dyJAyjEry54pN2UqJKAB16'
  .inspect()
  
  
  

idToSimpleTransactions = -> 
  pipeline  requestOptions(),
            request(),
            JSONStream.parse(),
            simpleTransactions()