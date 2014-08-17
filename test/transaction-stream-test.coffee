transactionStream = require '../src/transaction-stream'
sinon = require 'sinon'
assert = require 'assert'


it 'subscribes to account and streams it', (done) ->

  clock = sinon.useFakeTimers();

  fakeWebSocketInstance =
    handlers: {}
    on: sinon.spy (event, callback) ->
      this.handlers[event] = callback
    fakeEmit: (event, obj) ->
      this.handlers[event](obj)
    send: sinon.spy()
  fakeWebSocketConstructor = sinon.stub().returns(fakeWebSocketInstance)

  testSubject = transactionStream(fakeWebSocketConstructor, 'gDSSa75HPagWcvQmwH7D51dT5DPmvsKL4q')

  assert(fakeWebSocketConstructor.calledWithNew())
  assert(fakeWebSocketConstructor.calledWith('ws://live.stellar.org:9001'))

  clock.tick 50

  fakeWebSocketInstance.fakeEmit 'open'

  clock.tick 100

  assert(fakeWebSocketInstance.send.calledWith(
    JSON.stringify({ "command" : "subscribe",   "accounts" : [ "gDSSa75HPagWcvQmwH7D51dT5DPmvsKL4q" ] })))

  testSubject.on 'data', (data) ->
    assert.deepEqual data,
      from: "gDSSa75HPagWcvQmwH7D51dT5DPmvsKL4q"
      to: "gM8ZuCaGB7GkCiLz7rW941boyVT2vW1ppT"
      date: 461599670
      amount: 50000000
    done()

  fakeWebSocketInstance.fakeEmit 'message', JSON.stringify({
     "transaction":{
        "Account":"gDSSa75HPagWcvQmwH7D51dT5DPmvsKL4q",
        "Amount":"50000000",
        "Destination":"gM8ZuCaGB7GkCiLz7rW941boyVT2vW1ppT",
        "TransactionType":"Payment",
        "date":461599670,
        "hash":"4FE01B5CB153EFC5825DB0BDDD8A4764D63FC55102E25277548A85B2B6277202"
     }
  })

  clock.restore()
