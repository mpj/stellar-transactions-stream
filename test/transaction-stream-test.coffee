transactionStream = require '../src/transaction-stream'
sinon = require 'sinon'
assert = require 'assert'

# TODO: start listening *after* subscribing



describe 'transaction-stream', ->
  world = null
  clock = null

  beforeEach ->
    world =
      given:
        fakeWebSocketConstructor: ->

          world.fakeWebSocketInstance =
            handlers: {}
            on: sinon.spy (event, callback) ->
              this.handlers[event] = callback
            fakeEmit: (event, obj) ->
              this.handlers[event](obj)
            send: sinon.stub()

          world.fakeWebSocketConstructor =
            sinon.stub().returns(world.fakeWebSocketInstance)
          world

    clock = sinon.useFakeTimers()

  afterEach -> clock.restore()

  it 'subscribes to account and streams it', (done) ->
    world.given.fakeWebSocketConstructor()

    testSubject = transactionStream(world.fakeWebSocketConstructor, 'gDSSa75HPagWcvQmwH7D51dT5DPmvsKL4q')

    assert(world.fakeWebSocketConstructor.calledWithNew())
    assert(world.fakeWebSocketConstructor.calledWith('ws://live.stellar.org:9001'))

    clock.tick 50

    world.fakeWebSocketInstance.fakeEmit 'open'

    clock.tick 100

    testSubject.on 'error', -> assert.fail('should not call error')

    world.fakeWebSocketInstance.send.yield null

    assert(world.fakeWebSocketInstance.send.calledWith(
      JSON.stringify({ "command" : "subscribe",   "accounts" : [ "gDSSa75HPagWcvQmwH7D51dT5DPmvsKL4q" ] })))

    testSubject.on 'data', (data) ->
      assert.deepEqual data,
        from: "gDSSa75HPagWcvQmwH7D51dT5DPmvsKL4q"
        to: "gM8ZuCaGB7GkCiLz7rW941boyVT2vW1ppT"
        date: 461599670
        amount: 50000000
      done()

    world.fakeWebSocketInstance.fakeEmit 'message', JSON.stringify({
       "transaction":{
          "Account":"gDSSa75HPagWcvQmwH7D51dT5DPmvsKL4q",
          "Amount":"50000000",
          "Destination":"gM8ZuCaGB7GkCiLz7rW941boyVT2vW1ppT",
          "TransactionType":"Payment",
          "date":461599670,
          "hash":"4FE01B5CB153EFC5825DB0BDDD8A4764D63FC55102E25277548A85B2B6277202"
       }
    })


  it 'forwards errors from on error', (done) ->
    world.given.fakeWebSocketConstructor()

    testSubject = transactionStream(world.fakeWebSocketConstructor, 'gDSSa75HPagWcvQmwH7D51dT5DPmvsKL4q')

    clock.tick 50

    fakeError = new Error()

    testSubject.on 'error', (error) ->
      assert.equal fakeError, error
      done()

    world.fakeWebSocketInstance.fakeEmit 'error', fakeError

  it 'forwards errors from send callback', (done) ->

    world.given.fakeWebSocketConstructor()

    testSubject = transactionStream(world.fakeWebSocketConstructor, 'gDSSa75HPagWcvQmwH7D51dT5DPmvsKL4q')

    clock.tick 50

    world.fakeWebSocketInstance.fakeEmit 'open'

    fakeError = new Error()
    testSubject.on 'error', (error) ->
      assert.equal fakeError, error
      done()

    world.fakeWebSocketInstance.send.yield fakeError
