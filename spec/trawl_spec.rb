require_relative '../helpers/helpers.rb'
require_relative '../helpers/trawl_helpers.rb'

RSpec.describe Helpers, '#partition_array' do
  elements = Random.rand(50..100)
  arr = [0..elements]
  partitions = Random.rand(2..5)
  context "#{elements} elements and #partitions{} partitions" do
    partitioned_arr = Helpers.partition_array(arr, partitions)
    it 'contains the right number of partitions' do
      expect(partitioned_arr.length).to eq partitions
    end
    it 'contains all the original values' do
      expect(partitioned_arr.flatten).to eq arr
    end
  end
end

RSpec.describe Helpers, '#filter_cutoff' do
  inp = {}
  elements = Random.rand(50..1000)
  (1..elements).map { |i| inp[i] = i }
  lower = Random.rand(5..40).to_f / 100.0
  upper = Random.rand(5..40).to_f / 100.0
  expected_lower = (lower * elements).round
  expected_upper = (upper * elements).round
  out = Helpers.filter_cutoff(Hash[*inp.to_a.shuffle.flatten(1)], lower, upper)
  context "\n\telements: #{elements}\n\tlower: #{lower}\n\tupper: #{upper}\n" do
    it 'produces hash with right lower size' do
      expect(out[:lower].size).to eq expected_lower
    end
    it 'produces hash with right upper size' do
      expect(out[:upper].size).to eq expected_upper
    end
    it 'produces the right lower values' do
      inp.keys[0...expected_lower].each do |element|
        expect(out[:lower].include?(element)).to eq true
      end
    end
    it 'produces the right upper values' do
      inp.keys[-expected_upper..-1].each do |element|
        expect(out[:upper].include?(element)).to eq true
      end
    end
  end
end

RSpec.describe TrawlHelpers, '#retrieve_price' do
  context 'given a ticker, period, and attributes' do
    attribute_1 = 'close'
    attribute_2 = 'open'
    ticker = 'KO'
    period = '5d'
    it 'retrieves a single attribute' do
      out = TrawlHelpers.retrieve_price(ticker, period, attribute_1)
      out.each do |date, values|
        is_number = values[attribute_1].is_a?(Float) || values[attribute_1].is_a?(Integer)
        is_number.should eq true
      end
    end
    it 'retrieves a two attributes' do
      out = TrawlHelpers.retrieve_price(ticker, period, attribute_1, attribute_2)
      out.each do |date, values|
        is_1_number = values[attribute_1].is_a?(Float) || values[attribute_1].is_a?(Integer)
        is_2_number = values[attribute_2].is_a?(Float) || values[attribute_2].is_a?(Integer)
        (is_1_number && is_2_number).should eq true
      end
    end
  end
end

RSpec.describe TrawlHelpers, '#calc_proximity_momentum' do
  prices = { a: 1.0, b: 2.0, c: 1.0, d: 1.0, e: 1.0, f: 1.0, g: 2.0, h: 4.0, i: 2.0, j: 8.0 }
  momentum_duration = 5
  expected_out = { f: 0.5, g: 1.0, h: 2.0, i: 0.5, j: 2.0 }
  context 'a momentum duration and a hash of dates and prices' do
    it 'calculates proximity momentum' do
      out = TrawlHelpers.calc_proximity_momentum(prices, momentum_duration)
      expect(out).to eq expected_out
    end
  end
end
