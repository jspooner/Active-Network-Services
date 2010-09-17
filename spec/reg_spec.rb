# Require the spec helper relative to this file
require File.join(File.dirname(__FILE__), %w[spec_helper])
require File.join(File.dirname(__FILE__), %w[custom_matchers_spec])
require File.join(File.dirname(__FILE__), %w[ .. lib services search])
require File.join(File.dirname(__FILE__), %w[ .. lib services activity])
require File.join(File.dirname(__FILE__), %w[ .. lib services reg_center])
include Active::Services

describe RegCenter do
  before(:each) do 
    @valid_id = "D9A22F33-8A14-4175-8D5B-D11578212A98"
  end
  it "should set find by id" do
    a = RegCenter.find_by_id(@valid_id)
    a.asset_id.should == @valid_id
  end
  it "should get the asset_type_id" do
    RegCenter.find_by_id(@valid_id).asset_id_type.should_not be_nil
  end
  it "should thorw an RegCenterError if no record is found" do
    lambda { RegCenter.find_by_id( "666" ) }.should raise_error(RegCenterError)                         
  end
  it "should get the API metadata" do
    a = RegCenter.find_by_id(@valid_id)
    a.data["event"].should_not be_nil
  end
  it "should have more details than ATS" do
    a = ATS.find_by_id(@valid_id)
    b = RegCenter.find_by_id(@valid_id)
    a.address[:address].should be_nil
    b.address[:address].should_not be_nil
  end
  it "should only load API metadata once" do
    a = RegCenter.find_by_id(@valid_id)
    puts a.url
    puts a.address
    RegCenter.should_receive(:get_app_api).once
  end
  it "should have an address Hash" do
    a = RegCenter.find_by_id(@valid_id)
    a.address.should be_an_instance_of(Hash)
  end
  it "should cleanup title" do
    a = ATS.find_by_id(@valid_id)
    a.title.should_not_contain("\r")
  end
  it "should have a title String" do
    a = ATS.find_by_id(@valid_id)
    a.title.should be_an_instance_of(String)
  end
  
  
end
