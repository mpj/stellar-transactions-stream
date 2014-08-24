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
    passed = []    
    timeoutHandle = null
    
    onError = (err) -> 
      clearTimeout timeoutHandle
      failed = true
      callback err, null, passed
    
    env = domain.create();
    env.on 'error', onError
    
    try
      env.run ->
        
        transform = constructor()
        transform.on 'data', (data) ->
          if not failed
            clearTimeout timeoutHandle
            # has some problems with the through stream
            # passing an error and then the input message,
            # funky. Either way, we're not interested in 
            # anything if there is an error happening.
            callback null, data, passed
        
        transform.on 'passed', (data) -> passed.push data
        
        doTimeout = ->
          if not failed
            failed = true
            err = new Error 'Timed out'
            callback err, null, passed
        timeoutHandle = setTimeout doTimeout, 1000
        
        transform.write givenObj
        

    catch err
      onError err
  

      
      
  printLog = (opts) ->
    { givenObj, expectedObj, yieldedObj, passed, error } = opts
    console.log ''
    console.log "Given:"
    console.log prettyjson.render givenObj
    console.log ''
    if passed
      passed.forEach (data, i) ->
        return if i is 0
        console.log "Passed ("+i+"):"
        console.log prettyjson.render data
        console.log ''
      
    if expectedObj
      console.log "Expected:"
      console.log prettyjson.render expectedObj
      console.log ''
    if error
      console.log "Yielded "+ "error".red + ":"
      message = error.stack or error.message 
      console.log message.red
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
            simulate transformConstructor, givenObj, (error, yieldedObj, passed) ->
              console.log "* INSPECTING: ".magenta + description
              console.log ''
              yieldedObj = yieldedObjectMapper(yieldedObj)
              printLog { givenObj, yieldedObj, passed, error }
          specHandle
    exec: -> onExec.forEach (fn) -> fn()
  specHandle

module.exports = spec