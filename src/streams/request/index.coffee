module.exports = ->
  _.thorugh (s) -> s.flatMap (requestOptions) -> request(requestOptions)