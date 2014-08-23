subject = require './'
spec = require '../../tools/stream-spec'

module.exports = spec(subject)
  .case 'Converts to simple format'
  .given {
    "result": {
      "transactions": [
        {
          "tx": {
            "Account": "gEAZjCR4PUK8dyJAyjEry54pN2UqJKAB16",
            "Amount": "1000000",
            "Destination": "g3J3rBZk5frd5TWB58sHECMFDw3mPB4c7o",
            "TransactionType": "Payment",
            "date": 461710030,
          }
        }
      ]
    }
  }
  .yields [
    {
      "from": "gEAZjCR4PUK8dyJAyjEry54pN2UqJKAB16",
      "to": "g3J3rBZk5frd5TWB58sHECMFDw3mPB4c7o",
      "amount": "1000000",
      "date": "2014-08-18T20:47:10.000Z"
    }
  ]
  
  .case 'Filters non-payment transactions'
  .given {
    "result": {
      "transactions": [
        {
          "tx": {
            "TransactionType": "SOMETHINGELSE",
            "WIERD_PROPERTY": 51221,
          }
        },
        {
          "tx": {
            "Account": "gEAZjCR4PUK8dyJAyjEry54pN2UqJKAB16",
            "Amount": "1000000",
            "Destination": "g3J3rBZk5frd5TWB58sHECMFDw3mPB4c7o",
            "TransactionType": "Payment",
            "date": 464736610,
          }
        }
      ]
    }
  }
  .yieldsExactly [
    {
      "from": "gEAZjCR4PUK8dyJAyjEry54pN2UqJKAB16",
      "to": "g3J3rBZk5frd5TWB58sHECMFDw3mPB4c7o",
      "amount": "1000000",
      "date": "2014-09-22T21:30:10.000Z"
    }
  ]

  
