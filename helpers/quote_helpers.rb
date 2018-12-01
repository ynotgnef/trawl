# quote helpers
module QuoteHelpers
  require 'stock_quote'

  module_function

  def call_quote(tickers, duration = '1y')
    res = StockQuote::Stock.batch('chart', tickers, duration)
    #partition into days
  end
end
