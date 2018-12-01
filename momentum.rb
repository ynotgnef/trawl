require 'stock_quote'
require 'parallel'
require_relative './helpers/helpers.rb'
require_relative './helpers/trawl_helpers.rb'

processes = 2#ENV['P_PROCESSES'].to_i
threads = 3#ENV['P_THREADS'].to_i
tickers = File.read('results/ticker_list.txt').split
tickers = Helpers.partition_array(tickers, processes)

momentum_transform = {
  method: TrawlHelpers.method('retrieve_and_calc_momentum'),
  params: [250, '5y']
}

res = Helpers.parallelize(tickers, momentum_transform, threads, processes)
res = Helpers.merge_all!(res)
position = {}
res.each do |date, data|
  position[date] = Helpers.filter_cutoff(data, 0.1, 0.1)
end

File.open('./results/temp.txt', 'w') do |f|
  f.write(position)
end

#when we do calculate performance, have to generate a list of dates to compare against the postitions
