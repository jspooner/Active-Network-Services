# Require the spec helper relative to this file
require File.join(File.dirname(__FILE__), %w[spec_helper])
require File.join(File.dirname(__FILE__), %w[custom_matchers_spec])
require File.join(File.dirname(__FILE__), %w[ .. lib services search])
require File.join(File.dirname(__FILE__), %w[ .. lib services activity])
require File.join(File.dirname(__FILE__), %w[ .. lib services reg_center])
include Active::Services

describe ActiveWorks do
  before(:each) do 
    @valid_id = "E-00072ZDN"
  end
  it "should set find by id" do
    a = ActiveWorks.find_by_id(@valid_id)
    a.data["id"].should == @valid_id
  end
  it "should have a nil user email" do
    a = ActiveWorks.find_by_id(@valid_id)
    a.user.email.should be_nil    
  end
  it "should set the asset_type_id" do
    ActiveWorks.find_by_id(@valid_id).asset_type_id.should_not be_nil
  end
  it "should thorw an ActiveWorksError if no record is found" do
    lambda { ActiveWorks.find_by_id( "666" ) }.should raise_error(ActiveWorksError)                         
  end
  it "should get the API metadata" do
    a = ActiveWorks.find_by_id(@valid_id)
    a.data["eventDetailDto"].should_not be_nil
  end
  it "should have an address Hash" do
    a = ActiveWorks.find_by_id(@valid_id)
    a.address.should be_an_instance_of(HashWithIndifferentAccess)
  end
  it "should have a desc" do
    a = ActiveWorks.find_by_id(@valid_id)
    a.desc.should_not == ""
    a.desc.should_not == nil
  end
  it "should cleanup desc" do
    a = ActiveWorks.find_by_id(@valid_id)
    puts a.desc
    a.desc.should_not include('\"')
  end
  it "should have a title String" do
    a = ActiveWorks.find_by_id(@valid_id)
    a.title.should be_an_instance_of(String)
  end
  it "should have a start_date DateTime" do
    a = ActiveWorks.find_by_id(@valid_id)
    puts a.start_date
    a.start_date.should be_an_instance_of(DateTime)
  end
  it "should have a start_time DateTime" do
    a = ActiveWorks.find_by_id(@valid_id)
    a.start_time.should be_an_instance_of(DateTime)
  end
  
  
end
