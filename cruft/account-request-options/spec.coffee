
module.exports = (spec) ->
  spec.
    describe 'requestOptions generates request options'
      .given 'gEAZjCR4PUK8dyJAyjEry54pN2UqJKAB16'
      .yields
        "method": "POST",
        "uri": "https://live.stellar.org:9002",
        "body": "{\"method\":\"account_tx\",\"params\":[{\"account\":\"gEAZjCR4PUK8dyJAyjEry54pN2UqJKAB16\"}]}"
      
      .describe 'requestOptions generates request options (alternate)'
      .given 'gDSSa75HPagWcvQmwH7D51dT5DPmvsKL4q'
      .yields
        "method": "POST",
        "uri": "https://live.stellar.org:9002",
        "body": "{\"method\":\"account_tx\",\"params\":[{\"account\":\"gDSSa75HPagWcvQmwH7D51dT5DPmvsKL4q\"}]}"