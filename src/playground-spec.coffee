account = 'gEAZjCR4PUK8dyJAyjEry54pN2UqJKAB16'
spec = require './tools/stream-spec'
_ = require 'highland'
JSONStream = require 'JSONStream'

prop = require 'mout/function/prop'
es = require 'event-stream'

request = require './streams/request'
requestOptions = require './streams/request-options'
simpleTransactions = require './streams/simple-transactions'



subject  = ->
  _.pipeline _.through(requestOptions()),
             _.through(request())
             _.through(JSONStream.parse())
             _.through(simpleTransactions())
             
module.exports = spec(subject)
  .case()
  .given(account)
  .inspect()
  
  
  
  