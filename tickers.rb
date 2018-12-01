require_relative './helpers/helpers.rb'
require_relative './helpers/trawl_helpers.rb'

configs = Helpers.load_yaml('config/configs.yml')
ticker_list = TrawlHelpers.generate_ticker_list('results/ticker_list.txt', configs)
File.open('results/ticker_list.txt', 'w') { |f|
  f.write(ticker_list.join("\n"))
}
puts 'Successfully generated ticker list'
