streamSpec = require '../../tools/stream-spec'
fetchNameRequestOptions = require './index'
module.exports = 
  streamSpec(fetchNameRequestOptions)
    .case('Generates correct request')
    .given 'gEAZjCR4PUK8dyJAyjEry54pN2UqJKAB16'
    .yields {
      "method": "GET",
      "uri": "https://api.stellar.org/reverseFederation?domain=stellar.org&destination_address=gEAZjCR4PUK8dyJAyjEry54pN2UqJKAB16"
    }

  