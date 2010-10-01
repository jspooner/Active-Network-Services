# Require the spec helper relative to this file
require File.join(File.dirname(__FILE__), %w[spec_helper])
require File.join(File.dirname(__FILE__), %w[ .. lib services search])
require File.join(File.dirname(__FILE__), %w[ .. lib services activity])
require File.join(File.dirname(__FILE__), %w[ .. lib services IActivity])

# No need to type Britify:: before each call
include Active::Services

describe Activity do

  before(:each) do 
    @ats = ATS.find_by_id("A9EF9D79-F859-4443-A9BB-91E1833DF2D5")
    @gsa = Search.search({:asset_id=>"4f698038-3a02-cf94-5d34-495fa28479dc", :start_date=>"01/01/2000"}).results.first
#    @gsa = Search.search({:asset_id=>"6589BA2E-793A-4317-822F-6937511BE73B", :start_date=>"01/01/2000"}).results.first
    @reg = RegCenter.find_by_id("1889826")
    @works = ActiveWorks.find_by_id("E-00072ZDN")
  end

  it "should retrive data from GSA" do
    a = Activity.new(@gsa,true)
    a.primary.should be_an_instance_of(ActiveWorks)
    a.gsa.should be_an_instance_of(GSA)
    a.ats.should be_an_instance_of(ATS)
  end

  it "should retrive data from ATS" do
    a = Activity.new(@ats,true)
    a.primary.should be_an_instance_of(RegCenter)
    a.gsa.should be_an_instance_of(GSA)
    a.ats.should be_an_instance_of(ATS)
  end

  it "should retrive data from Reg" do
    a = Activity.new(@reg,true)
    a.primary.should be_an_instance_of(RegCenter)
    a.gsa.should be_an_instance_of(GSA)
    a.ats.should be_an_instance_of(ATS)
  end

  it "should retrive data from Works" do
    a = Activity.new(@works,true)
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
    a.address.length.should be > 1
  end

  it "should have zip with proper length" do
    a = Activity.new(@gsa)
    a.address["zip"].length.should be (0 || 5 || 10)
  end

  it "should have lat length > 0" do
    a = Activity.new(@ats)
    a.address["lat"].length.should be > 0
  end

  it "should have lon length > 0" do
    a = Activity.new(@gsa)
    puts a.address.inspect
    a.address["lng"].length.should be > 0
  end

end
