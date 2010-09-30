# Require the spec helper relative to this file
require File.join(File.dirname(__FILE__), %w[spec_helper])
require File.join(File.dirname(__FILE__), %w[custom_matchers_spec])
require File.join(File.dirname(__FILE__), %w[ .. lib services search])
require File.join(File.dirname(__FILE__), %w[ .. lib services activity])
require File.join(File.dirname(__FILE__), %w[ .. lib services reg_center])
include Active::Services

describe RegCenter do
  before(:each) do 
#    @valid_id = "1802851"
    @valid_id = "1877942"
#    @valid_id = "1889826"
#    @valid_id = "1847738"
  end
  it "should set find by id" do
    a = RegCenter.find_by_id(@valid_id)
    puts a.data.inspect
    a.data["id"].should == @valid_id
  end
  it "should set the asset_type_id" do
    RegCenter.find_by_id(@valid_id).asset_type_id.should_not be_nil
  end
  it "should thorw an RegCenterError if no record is found" do
    lambda { RegCenter.find_by_id( "666" ) }.should raise_error(RegCenterError)                         
  end
  it "should get the API metadata" do
    a = RegCenter.find_by_id(@valid_id)
    a.data["event"].should_not be_nil
  end
  it "should have an address Hash" do
    a = RegCenter.find_by_id(@valid_id)
    a.address.should be_an_instance_of(HashWithIndifferentAccess)
  end
  it "should have a desc String" do
    a = RegCenter.find_by_id(@valid_id)
    a.desc.should be_an_instance_of(String)
  end
  it "should cleanup title" do
    a = RegCenter.find_by_id(@valid_id)
    a.title.should_not include("\r")
  end
  # it "should have a primary category" do
  #   a = RegCenter.find_by_id(@valid_id)
  #   puts a.primary_category
  #   a.primary_category.should_not be_nil
  # end
  it "should have a title String" do
    a = RegCenter.find_by_id(@valid_id)
    a.title.should be_an_instance_of(String)
  end
  it "should have a categories array" do
    a = RegCenter.find_by_id(@valid_id)
    puts a.categories.inspect
    a.categories.should be_an_instance_of(Array)
  end
  # it "should have a category" do
  #   a = RegCenter.find_by_id(@valid_id)
  #   a.category.should be_an_instance_of(String)
  # end
  it "should have a start_date DateTime" do
    a = RegCenter.find_by_id(@valid_id)
    puts a.start_date
    a.start_date.should be_an_instance_of(DateTime)
  end
  it "should have a start_time DateTime" do
    a = RegCenter.find_by_id(@valid_id)
    a.start_time.should be_an_instance_of(DateTime)
  end
  
  
end
