assert = require 'assert'
_ = require 'highland'
prettyjson =
  render: (x) -> 
    JSON.stringify x, null, 2
deepMatches = require 'mout/object/deepMatches'
colors = require 'colors'
isFunction = require 'mout/lang/isFunction'

      
  ## TODO pass in map function to inspect
  ## TODO save inspect output to file
  #.inspect()
  # TODO: Make a transform constructor. I.e
  # adder = transform (operators) ->
  #   operators.left + operators.right
  # (the above should also be able to return streams

spec = (transformConstructor) ->
  if not isFunction(transformConstructor)
    console.warn 'This tool only handles transform stream constructors. Was passed', transformConstructor
    return

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
      
      
  printLog = (opts) ->
    { givenObj, expectedObj, yieldedObj, error } = opts
    console.log ''
    console.log "Given:"
    console.log prettyjson.render givenObj
    console.log ''
    if expectedObj
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
        
  onExec = []
  
  specHandle = 
    case: (description) ->
      description ||= 'Untitled case'
      given: (givenObj) ->
        yields: (expectedObj) ->
          onExec.push ->
            simulate transformConstructor, givenObj, (error, yieldedObj) ->
              if not deepMatches yieldedObj, expectedObj
                console.log "* NOT FULFILLED: ".red + description
                printLog { givenObj, yieldedObj, expectedObj, error }
              else
                console.log "* FULFILLED: ".green + description
          specHandle
        inspect: ->
          onExec.push ->
            simulate transformConstructor, givenObj, (error, yieldedObj) ->
              console.log "* INSPECTING: ".magenta + description
              console.log ''
              printLog { givenObj, yieldedObj, error }
          specHandle
    exec: -> onExec.forEach (fn) -> fn()
  specHandle

module.exports = spec