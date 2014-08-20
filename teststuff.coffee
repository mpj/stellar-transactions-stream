assert = require 'assert'
_ = require 'highland'
prettyjson = require 'prettyjson'
deepEquals = require 'mout/object/deepEquals'
colors = require 'colors'

spec = (transformConstructor) ->
  console.log '--- Running spec --- '

  simulate = (constructor, givenObj, callback) ->
    transform = constructor()
    faux = _()
    x = faux.through(transform)
    x.on 'data', _.partial(callback, null)
    x.on 'error', callback
    try
      faux.write givenObj
    catch err
      callback err



  specInstance =
    given: (givenObj) ->
      specInstance.describe('Unnamed case').given(givenObj)
    describe: (description) ->
      given: (givenObj) ->
        yields: (expectedObj) ->
          simulate transformConstructor, givenObj, (error, yieldedObj) ->
            if not deepEquals yieldedObj, expectedObj
              console.log "* NOT FULFILLED: ".red + description
              console.log ''
              console.log "Expected:"
              console.log prettyjson.render expectedObj
              console.log ''
              if error
                console.log "Yielded "+ "error".red + ":"
                console.log error.stack.red
              else
                console.log "Yielded:"
                console.log prettyjson.render yieldedObj
              console.log ''
              console.log "Given:"
              console.log prettyjson.render givenObj
              console.log ''
            else
              console.log "* FULFILLED: ".green + description
          specInstance
        inspect: ->
          simulate transformConstructor, givenObj, (error, yieldedObj) ->
            console.log "* INSPECTING: ".magenta + description
            console.log ''
            if error
              console.log "Yielded "+ "error".red + ":"
              console.log error.stack.red
            else
              console.log "Yielded:"
              console.log prettyjson.render yieldedObj
            console.log ''
            console.log "Given:"
            console.log prettyjson.render givenObj
            console.log ''


          specInstance



currentStransactions = require './current-transactions'

spec(currentStransactions)
  .given('gEAZjCR4PUK8dyJAyjEry54pN2UqJKAB16')
  .inspect()
