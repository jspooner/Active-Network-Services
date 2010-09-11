require 'rubygems'
require File.expand_path(File.join(File.dirname(__FILE__), %w[.. .. lib Active]))
include Active::Services

Benchmark.bm(700) do |x|
  x.report("string:")   { Search.new({:keywords => "running,swimming,yoga"}) }
  x.report("array:") { Search.new({:keywords => %w(running swimming yoga)}) }
  x.report("Array:")  { Search.new({:keywords => ["running","swimming","yoga"]}) }
end