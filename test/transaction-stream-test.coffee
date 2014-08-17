transactionStream = require '../src/transaction-stream'
sinon = require 'sinon'
assert = require 'assert'

# TODO: start listening *after* subscribing



describe 'transaction-stream', ->
  world = null
  clock = null

  beforeEach ->
    clock = sinon.useFakeTimers()
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
          world.given

        testSubjectCalledWithSomeAccount: ->
          world.someAccount = 'gDSSa75HPagWcvQmwH7D51dT5DPmvsKL4q'
          world.returnedStream =
            transactionStream(world.fakeWebSocketConstructor, world.someAccount)
          world.given

        socketOpensSuccessFully: ->
          world.fakeWebSocketInstance.fakeEmit 'open'
          world.given

        sendCommandYieldsSuccessfully: ->
          world.fakeWebSocketInstance.send.yield null
          world.given

        fakeErrorHandler: ->
          world.fakeErrorHandler = sinon.spy()
          world.returnedStream.on 'error', world.fakeErrorHandler
          world.given

        fakeDataHandler: ->
          world.fakeDataHandler = sinon.spy()
          world.returnedStream.on 'data', world.fakeDataHandler
          world.given

    world.when = world.given


  afterEach -> clock.restore()

  describe 'given test subject is called with a web socket constructor', ->
    beforeEach ->
      world.given
        .fakeWebSocketConstructor()
        .testSubjectCalledWithSomeAccount()
        .fakeErrorHandler()
        .fakeDataHandler()

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
        world.given.socketOpensSuccessFully()

      it 'then it sends a subscription command', () ->
        clock.tick 1
        expectedPayload = JSON.stringify
          "command" : "subscribe"
          "accounts" : [ world.someAccount ]

        assert world.fakeWebSocketInstance.send.calledWith expectedPayload

      describe 'given subscription is successful', ->
        beforeEach ->
          world.given.sendCommandYieldsSuccessfully()

        it 'then it does NOT send error', ->
          assert world.fakeErrorHandler.callCount is 0

        describe 'given websocket sends data', ->
          beforeEach ->
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

          it 'then it sends simplified transaction', ->
            assert world.fakeDataHandler.calledWith
              from: "gDSSa75HPagWcvQmwH7D51dT5DPmvsKL4q"
              to: "gM8ZuCaGB7GkCiLz7rW941boyVT2vW1ppT"
              date: 461599670
              amount: 50000000

      describe 'given subscription fails', ->
        fakeError = null
        beforeEach ->
          fakeError = new Error()
          world.fakeWebSocketInstance.send.yield fakeError

        it 'then it will be passed to error handler', ->
          assert(world.fakeErrorHandler.calledWith(fakeError))
