# trawl helpers
module TrawlHelpers
  require 'nokogiri'
  require 'rest-client'
  require 'stock_quote'

  module_function

  def parse_screener_content(screener_content)
    tickers = []
    screener_links = Nokogiri::HTML(screener_content).css('a').map { |link| link.to_s }
    screener_links.each do |link|
      next unless link =~ /screener-link-primary/
      ticker = link.match(/>(.*)</)[1]
      tickers << ticker
    end
    tickers
  end

  def list_all_tickers(screener_endpoint, screener_count, screener_increment, stop_at = nil)
    tickers = []
    loop do
      res = RestClient.get("#{screener_endpoint}#{screener_count}")
      page_tickers = parse_screener_content(res.body)
      break if page_tickers[-1] == tickers[-1]
      break if stop_at && screener_count > stop_at
      screener_count += screener_increment
      tickers.concat page_tickers
    end
    tickers
  end

  def retrieve_tickers_list(tickers_url, username, password)
    res = RestClient::Request.new(
      method: :get,
      url: tickers_url,
      user: username,
      password: password
    ).execute
    raise 'Unable to retrieve tickers list' unless res.code == 200
    res.body.split("\n")
  end

  def partition_tickers(tickers, partition_size)
    partitions = []
    partitions << tickers.shift(partition_size) until tickers.empty?
    partitions
  end

  def generate_ticker_list(output_file, configs, stop_at = nil)
    screener_endpoint = configs['screener_endpoint']
    increment = configs['screener_increment']
    TrawlHelpers.list_all_tickers(screener_endpoint, 1, increment, stop_at)
  end

  def retrieve_price(ticker, period, *attributes)
    out = {}
    StockQuote::Stock.batch('chart', ticker, period).chart.each do |date|
      out[date['date']] = {}
      attributes.each do |attribute|
        out[date['date']][attribute] = date[attribute]
      end
    end
    out
  end

  def calc_proximity_momentum(prices, momentum_duration)
    out = {}
    keys = prices.keys
    values = prices.values
    lower_bound = 0
    loop do
      upper_bound = lower_bound + momentum_duration - 1
      break unless keys[upper_bound + 1]
      momentum = values[upper_bound + 1] / values[lower_bound..upper_bound].max
      out[keys[upper_bound + 1]] = momentum
      lower_bound += 1
    end
    out
  end

  def retrieve_and_calc_momentum(ticker, momentum_duration, period)
    data = TrawlHelpers.retrieve_price(ticker, period, 'close')
    data.each do |date, close|
      data[date] = close['close']
    end
    out = TrawlHelpers.calc_proximity_momentum(data, momentum_duration)
    out.each do |date, momentum|
      out[date] = { ticker => momentum }
    end
  end
end
