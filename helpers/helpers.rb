# trawl helpers
module Helpers
  require 'erb'
  require 'parallel'
  require 'yaml'

  module_function

  def load_yaml(file_path)
    YAML.load(ERB.new(File.read(file_path)).result) || {}
  rescue SystemCallError
    raise "Could not load file: '#{file_path}"
  end

  def parallelize(dataset, handler, threads = 1, processes = 1)
    Parallel.map(dataset, in_processes: processes) do |group|
      process_res = {}
      Parallel.each(group, in_threads: threads) do |ticker|
        e = process_res.empty?
        process_res.deep_merge!(handler[:method].call(ticker, *handler[:params]))
      end
      process_res
    end
  end

  def partition_array(arr, groups = 2)
    arr = arr.clone
    out = []
    length = arr.length
    quotient = length / groups
    remainder = length.modulo(groups)
    0.upto(groups - 1) do |group|
      group_elements = group < remainder ? quotient + 1 : quotient
      out << arr.shift(group_elements)
    end
    out
  end

  def filter_cutoff(data, lower_cutoff = 0.1, upper_cutoff = 0.1)
    lower_bound = data.length * lower_cutoff
    upper_bound = data.length * upper_cutoff
    keys = Hash[data.sort_by { |_, value| value }].keys
    { lower: keys[0...lower_bound.round], upper: keys[-upper_bound.round..-1] }
  end

  class ::Hash
    def deep_merge!(second)
      merger = proc { |key, v1, v2| Hash === v1 && Hash === v2 ? v1.merge(v2, &merger) : Array === v1 && Array === v2 ? v1 | v2 : [:undefined, nil, :nil].include?(v2) ? v1 : v2 }
      self.merge!(second.to_h, &merger)
    end
  end

  def merge_all!(arr)
    1.upto(arr.length-1) do |entry|
      arr[0].deep_merge!(arr[entry])
    end
    arr[0]
  end
end
