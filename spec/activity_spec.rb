# Require the spec helper relative to this file
require File.join(File.dirname(__FILE__), %w[spec_helper])
require File.join(File.dirname(__FILE__), %w[ .. lib services search])
require File.join(File.dirname(__FILE__), %w[ .. lib services activity])
require File.join(File.dirname(__FILE__), %w[ .. lib services IActivity])

# No need to type Britify:: before each call
include Active::Services

describe Activity do

  before(:each) do 
    @ats = ATS.find_by_id ("A9EF9D79-F859-4443-A9BB-91E1833DF2D5")
#    @gsa = Search.search({:asset_id=>"4f698038-3a02-cf94-5d34-495fa28479dc", :start_date=>"01/01/2000"}).results.first
    @gsa = Search.search({:asset_id=>"6589BA2E-793A-4317-822F-6937511BE73B", :start_date=>"01/01/2000"}).results.first
    @reg = RegCenter.find_by_id("1889826")
    @works = ActiveWorks.find_by_id("E-00072ZDN")
  end

  it "should retrive data from GSA" do
    a = Activity.new(@gsa)
    a.primary.should be_an_instance_of(ActiveWorks)
    a.gsa.should be_an_instance_of(GSA)
    a.ats.should be_an_instance_of(ATS)
  end

  it "should retrive data from ATS" do
    a = Activity.new(@ats)
    a.primary.should be_an_instance_of(RegCenter)
    a.gsa.should be_an_instance_of(GSA)
    a.ats.should be_an_instance_of(ATS)
  end

  it "should retrive data from Reg" do
    a = Activity.new(@reg)
    a.primary.should be_an_instance_of(RegCenter)
    a.gsa.should be_an_instance_of(GSA)
    a.ats.should be_an_instance_of(ATS)
  end

  it "should retrive data from Works" do
    a = Activity.new(@works)
    a.primary.should be_an_instance_of(ActiveWorks)
    a.gsa.should be_an_instance_of(GSA)
    a.ats.should be_an_instance_of(ATS)
  end

  it "should have address not nil" do
    a = Activity.new(@gsa)
    a.address.should_not be nil
  end

  it "should have address with length > 1" do
     a = Activity.new(@gsa)
     a.address.length.should be > 1
   end
 
   it "should have address type Hash" do
      a = Activity.new(@gsa)
      a.address.should be_an_instance_of(HashWithIndifferentAccess)
    end
 
  it "should have address with length > 1" do
    a = Activity.new(@gsa)
    puts a.address.inspect
#    {"name"=>"", "address"=>"TBA", "city"=>"Joplin", "zip"=>"00000", "country"=>"United States", "lng"=>"", "lat"=>"", "state"=>"MO"}
    a.address.length.should be > 1
  end
    # [9/30/10 11:17:57 AM] Jonathan Spooner: 2 a.address.address.length should be larger then 1
    # [9/30/10 11:18:20 AM] Jonathan Spooner: 3. Lets say the address in Reg looks like this
    # [9/30/10 11:19:24 AM] Jonathan Spooner: 55 or friars road | lat 22
    # [9/30/10 11:20:26 AM] Jonathan Spooner: and we need to ensure the value is just "5505 friars rd"
    # [9/30/10 11:20:44 AM] Brian Levine: what is | lat 22
    # [9/30/10 11:20:52 AM] Brian Levine: brb

end
