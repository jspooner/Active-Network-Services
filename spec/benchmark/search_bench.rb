require 'rubygems'
require File.expand_path(File.join(File.dirname(__FILE__), %w[.. .. lib Active]))
include Active::Services

# Benchmark.bm(700) do |x|
#   x.report("string:")   { Search.new({:keywords => "running,swimming,yoga"}) }
#   x.report("array:") { Search.new({:keywords => %w(running swimming yoga)}) }
#   x.report("Array:")  { Search.new({:keywords => ["running","swimming","yoga"]}) }
# end
arr = []
Search.search(:num_results => 100, :page => 1).results.each do |a|
  match = (a.user.email == a.ats.contact_email)
  email = "--"
  if a.primary_source
    email = a.primary_source.user.email
  end
  arr << "#{a.asset_id}"
  arr << "                                    GSA= #{a.user.email}  ATS= #{a.ats.user.email}  #{a.primary_source}=> #{email} "
end
puts " "
puts " "
puts " "
puts " "
puts " "
puts arr