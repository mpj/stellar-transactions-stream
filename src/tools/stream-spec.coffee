assert = require 'assert'
prettyjson =
  render: (x) -> 
    JSON.stringify x, null, 2
deepMatches = require 'mout/object/deepMatches'
deepEquals = require 'deep-equal'
partial = require 'mout/function/partial'
colors = require 'colors'
isFunction = require 'mout/lang/isFunction'
domain = require 'domain'

      
  ## TODO pass in map function to inspect
  ## TODO save inspect output to file
  #.inspect()
  # TODO: Make a transform constructor. I.e
  # adder = transform (operators) ->
  #   operators.left + operators.right
  # (the above should also be able to return streams
  # TODO USe more specific test directories and format and be
  # more brittle - very annoying with silence when you forget
  # a module exports
  # TODO make inspect act like .only

spec = (transformConstructor) ->
  if not isFunction(transformConstructor)
    console.warn 'This tool only handles transform stream constructors. Was passed', transformConstructor
    return

  simulate = (constructor, givenObj, callback) ->

    failed = false
    onError = (err) -> 
      failed = true
      callback err
    
    env = domain.create();
    env.on 'error', onError
    
    try
      env.run ->
        transform = constructor()

        transform.on 'data', (data) ->
          if not failed
            # has some problems with the through stream
            # passing an error and then the input message,
            # funky. Either way, we're not interested in 
            # anything if there is an error happening.
            callback null, data
        transform.write givenObj
    catch err
      onError err
  

      
      
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
      console.log 'error is ', error
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
        yields = (comparator, expectedObj) -> 
          onExec.push ->
            simulate transformConstructor, givenObj, (error, yieldedObj) ->
              if not comparator yieldedObj, expectedObj
                console.log "* NOT FULFILLED: ".red + description
                printLog { givenObj, yieldedObj, expectedObj, error }
              else
                console.log "* FULFILLED: ".green + description
          specHandle
    
        yields: partial yields, deepMatches
        yieldsExactly: partial yields, deepEquals
          
        inspect: (yieldedObjectMapper) ->
          yieldedObjectMapper ||= 
            (obj) -> obj
          onExec.push ->
            simulate transformConstructor, givenObj, (error, yieldedObj) ->
              console.log "* INSPECTING: ".magenta + description
              console.log ''
              yieldedObj = yieldedObjectMapper(yieldedObj)
              printLog { givenObj, yieldedObj, error }
          specHandle
    exec: -> onExec.forEach (fn) -> fn()
  specHandle

module.exports = spec