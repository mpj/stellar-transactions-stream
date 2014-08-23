transactionStream = require '../src/transaction-subscribe-stream'
sinon = require 'sinon'
assert = require 'assert'

describe 'account-stream', ->
  world = null
  clock = null

  beforeEach ->
    clock = sinon.useFakeTimers()
    world = {}

  afterEach -> clock.restore()

  describe 'given test subject is called with a web socket constructor', ->
    beforeEach ->
      world.fakeWebSocketInstance =
        handlers: {}
        on: sinon.spy (event, callback) ->
          this.handlers[event] = callback
        fakeEmit: (event, obj) ->
          this.handlers[event](obj)
        send: sinon.stub()

      world.fakeWebSocketConstructor =
        sinon.stub().returns(world.fakeWebSocketInstance)

      world.someAccount = 'gDSSa75HPagWcvQmwH7D51dT5DPmvsKL4q'
      world.returnedStream =
        transactionStream(world.fakeWebSocketConstructor, world.someAccount)

      world.fakeErrorHandler = sinon.spy()
      world.returnedStream.on 'error', world.fakeErrorHandler

      world.fakeDataHandler = sinon.spy()
      world.returnedStream.on 'data', world.fakeDataHandler


    it 'constructs a stream', () ->
      assert(world.fakeWebSocketConstructor.calledWithNew())
      assert(world.fakeWebSocketConstructor.calledWith('ws://live.stellar.org:9001'))

    describe 'web socket emits an error', ->
      fakeError = null
      beforeEach ->
        fakeError = new Error()
        world.fakeWebSocketInstance.fakeEmit 'error', fakeError

      it 'then it will be passed to error handler', ->
        assert(world.fakeErrorHandler.calledWith(fakeError))

    describe 'given socket has been opened', ->
      beforeEach ->
        world.fakeWebSocketInstance.fakeEmit 'open'

      it 'then it sends a subscription command', () ->
        clock.tick 1
        expectedPayload = JSON.stringify
          "command" : "subscribe"
          "streams" :  [ "transactions" ]
          "accounts" : [ world.someAccount ]

        assert world.fakeWebSocketInstance.send.calledWith expectedPayload

      it 'should NOT YET listen to messages', ->
        assert not world.fakeWebSocketInstance.on.calledWith('message')

      describe 'given subscription is successful', ->
        beforeEach ->
          world.fakeWebSocketInstance.send.yield null

        it 'then it does NOT send error', ->
          assert world.fakeErrorHandler.callCount is 0

        describe 'given websocket sends a transaction', ->
          transaction = null
          beforeEach ->
            transaction =
             "other_prop": "hej"
             "transaction":{
                "Account":"gDSSa75HPagWcvQmwH7D51dT5DPmvsKL4q",
                "Amount":"50000000",
                "Destination":"gM8ZuCaGB7GkCiLz7rW941boyVT2vW1ppT",
                "TransactionType":"Payment",
                "date":461599670,
                "hash":"4FE01B5CB153EFC5825DB0BDDD8A4764D63FC55102E25277548A85B2B6277202"
             }
            world.fakeWebSocketInstance.fakeEmit 'message', JSON.stringify transaction

          it 'then it streams the transaction', ->
            assert world.fakeDataHandler.calledWith transaction

        describe 'given websocket sends an error response', ->
          fakeError = null
          beforeEach ->
            fakeError =
              "status":"error"
              "more_props": "here"
            world.fakeWebSocketInstance.fakeEmit 'message', JSON.stringify fakeError

          it 'then it will be passed to error handler', ->
            assert(world.fakeErrorHandler.calledWith(fakeError))

      describe 'given subscription fails', ->
        fakeError = null
        beforeEach ->
          fakeError = new Error()
          world.fakeWebSocketInstance.send.yield fakeError

        it 'then it will be passed to error handler', ->
          assert(world.fakeErrorHandler.calledWith(fakeError))
