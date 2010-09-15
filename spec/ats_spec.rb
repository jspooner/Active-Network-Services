# Require the spec helper relative to this file
require File.join(File.dirname(__FILE__), %w[spec_helper])
require File.join(File.dirname(__FILE__), %w[custom_matchers_spec])
require File.join(File.dirname(__FILE__), %w[ .. lib services search])
require File.join(File.dirname(__FILE__), %w[ .. lib services activity])
require File.join(File.dirname(__FILE__), %w[ .. lib services ats])
include Active::Services

describe ATS do
  before(:each) do 
    @valid_id = "A9EF9D79-F859-4443-A9BB-91E1833DF2D5"
  end
  it "should set find by id" do
    a = ATS.find_by_id(@valid_id)
    a.asset_id.should == @valid_id
  end
  it "should get the asset_type_id" do
    ATS.find_by_id(@valid_id).asset_id_type.should_not be_nil
  end
  it "should thorw an ATSError if no record is found" do
    lambda { ATS.find_by_id( "666" ) }.should raise_error(ATSError)                         
  end
  it "should have a title and desc ....." do
    
  end
  
  
end
