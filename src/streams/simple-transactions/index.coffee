prop = require 'mout/function/prop'
through = require 'through'
moment = require 'moment'

module.exports = -> through (response) -> 
  this.queue(
    response.result.transactions
      .map prop('tx')
      .filter (transaction) ->
        transaction.TransactionType is 'Payment'
      .map (transaction) ->
        
        from: transaction.Account
        to: transaction.Destination
        amount: transaction.Amount
        date: formatDate(transaction.date)
  )

# This will restun a ISO8601 formatted date string in UTC time zone.
# To parse ISO8601 to dates in local timezone, do this on the client:
# new Date(Date.parse(dateString))
formatDate = (stellarDate) ->
  # Convert ripple epoch to stellar epoch
  # See: https://ripple.com/wiki/JSON_API#time
  rippleEpoch = stellarDate
  unixEpoch = rippleEpoch + 946684800
  
  millisecondsSinceUnixEpoch = unixEpoch * 1000
  moment.utc(millisecondsSinceUnixEpoch).toISOString()

      