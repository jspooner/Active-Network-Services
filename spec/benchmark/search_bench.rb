require File.expand_path(File.join(File.dirname(__FILE__), %w[.. .. lib Active]))
include Active::Services

# Benchmark.bm(700) do |x|
#   x.report("string:")   { Search.new({:keywords => "running,swimming,yoga"}) }
#   x.report("array:") { Search.new({:keywords => %w(running swimming yoga)}) }
#   x.report("Array:")  { Search.new({:keywords => ["running","swimming","yoga"]}) }
# end

# arr = []
# Search.search(:num_results => 100, :page => 1).results.each do |a|
#   match = (a.user.email == a.ats.contact_email)
#   email = "--"
#   if a.primary_source
#     email = a.primary_source.user.email
#   end
#   arr << "#{a.asset_id}"
#   arr << "                                    GSA= #{a.user.email}  ATS= #{a.ats.user.email}  #{a.primary_source}=> #{email} "
# end
# puts " "
# puts " "
# puts " "
# puts " "
# puts " "
# puts arr

# puts Search.search(:asset_ids => ["DD8F427F-6188-465B-8C26-71BBA22D2DB7"]).results.inspect

REG_CENTER_ASSET_TYPE_ID   = "EA4E860A-9DCD-4DAA-A7CA-4A77AD194F65"
REG_CENTER_ASSET_TYPE_ID2  = "3BF82BBE-CF88-4E8C-A56F-78F5CE87E4C6"
ACTIVE_WORKS_ASSET_TYPE_ID = "DFAA997A-D591-44CA-9FB7-BF4A4C8984F1"

local_asset_type_id = "EC6E96A5-6900-4A0E-8B83-9AA935F45A73"
# puts "Local       " + Search.search({:asset_type_id => local_asset_type_id}).results.length.to_s

# loc = Search.search({:facet => "", :asset_type_id => local_asset_type_id, :start_date => Date.new(2008, 1, 1), :end_date => Date.new(2012, 11, 15) })
# loc = Search.search({:facet => "", :url => "local.active.com", :start_date => Date.new(2000, 1, 1), :end_date => Date.new(2019, 11, 15) })
# loc = Search.search({:facet => "", :url => "local.active.com"})

# puts "Local       " + loc.results.length.to_s
# puts loc.results.collect { |r| "#{r.origin}  #{r.title} #{r.url}" }


# puts "ActiveWorks " + Search.search({:asset_type_id => ACTIVE_WORKS_ASSET_TYPE_ID, :start_date => Date.new(2010, 1, 1), :end_date => Date.new(2011, 11, 15) }).results.length.to_s

# url = "www.active.com/running/long-branch-nj/new-jersey-marathon-and-long-branch-half-marathon-2011"
# r = Search.search({:url => url}).results  # , :start_date => Date.new(2011, 1, 1), :end_date => Date.new(2012, 1, 15)
# puts url
# puts "Results: #{r.length}"
# puts r.map(&:url)


s = Search.search({:bounding_box=>{:sw=>"36.893089,-123.533684", :ne=>"38.8643,-121.208199"}, :facet=>"", :end_date=>"+", :page=>1, :num_results=>10, :sort=>"date_asc", :start_date=>"today", :split_media_type=>nil})
puts s.numberOfResults
# puts r.map(&:url)