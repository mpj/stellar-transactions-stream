account = 'gEAZjCR4PUK8dyJAyjEry54pN2UqJKAB16'
spec = require './tools/stream-spec'
pipeline = require './tools/pipeline'
JSONStream = require 'JSONStream'


prop = require 'mout/function/prop'

request = require './streams/request'
requestOptions = require './streams/request-options'
simpleTransactions = require './streams/simple-transactions'


through = require 'through'


subject = -> pipeline requestOptions(),
                      request(),
                      JSONStream.parse(),
                      simpleTransactions()
                         
module.exports = spec(subject)
  .case()
  .given(account)
  .inspect()
  
  
  
