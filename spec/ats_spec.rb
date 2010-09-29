# Require the spec helper relative to this file
require File.join(File.dirname(__FILE__), %w[spec_helper])
require File.join(File.dirname(__FILE__), %w[custom_matchers_spec])
require File.join(File.dirname(__FILE__), %w[ .. lib services search])
require File.join(File.dirname(__FILE__), %w[ .. lib services activity])
require File.join(File.dirname(__FILE__), %w[ .. lib services ats])
include Active::Services

describe ATS do
  before(:each) do 
#    @valid_id = "A9EF9D79-F859-4443-A9BB-91E1833DF2D5"
    @valid_id="61BB7D71-EC01-46B8-A601-38CA1C9AE893"
    @reg_center_id = "D9A22F33-8A14-4175-8D5B-D11578212A98"
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
  it "should get the asset metadata" do
    ATS.get_asset_metadata(@valid_id).should_not be_nil
  end
  it "should load the asset metadata into @data" do
    a = ATS.find_by_id(@valid_id)
    a.load_metadata
    a.data["isSearchable"].should_not be_nil
  end
  it "should load the lazy the asset metadata" do
    a = ATS.find_by_id(@valid_id)
    puts a.url
    a.start_date.should_not be_nil
  end
  it "should only load metadata once" do
    a = ATS.find_by_id(@valid_id)
    puts a.url
    puts a.address
    ATS.should_receive(:load_metadata).once
  end
  it "should have an address Hash" do
    a = ATS.find_by_id(@valid_id)
    a.address.should be_an_instance_of(Hash)
  end
  it "should have a startDate Date" do
    a = ATS.find_by_id(@valid_id)
    a.start_date.should be_an_instance_of(Date)
  end
  it "should have a title String" do
    a = ATS.find_by_id(@valid_id)
    a.title.should be_an_instance_of(String)
  end
  
  
end
