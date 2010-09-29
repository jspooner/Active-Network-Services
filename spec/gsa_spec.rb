# Require the spec helper relative to this file
require File.join(File.dirname(__FILE__), %w[spec_helper])
require File.join(File.dirname(__FILE__), %w[custom_matchers_spec])
require File.join(File.dirname(__FILE__), %w[ .. lib services search])
require File.join(File.dirname(__FILE__), %w[ .. lib services activity])
require File.join(File.dirname(__FILE__), %w[ .. lib services reg_center])
require File.join(File.dirname(__FILE__), %w[ .. lib services address])
include Active::Services

describe GSA do
  before(:each) do 
    @a = Search.search(:keywords=>"run").results.first
  end
  it "should create from search" do
   @a.title.should_not be_nil
  end
  it "should set the asset_type_id" do
    puts @a.data["meta"].inspect
    @a.asset_type_id.should_not be_nil
  end
  it "should have an Address" do
    puts @a.address.inspect
    @a.address.should be_an_instance_of(Address)
  end
  it "should have a desc String" do
#    puts @a.data["meta"].keys.inspect
    puts @a.desc
    @a.desc.should be_an_instance_of(String)
  end
  it "should have a primary category" do
    @a.primary_category.should_not be_nil
  end
  it "should have a title String" do
    @a.title.should be_an_instance_of(String)
  end
  it "should have a categories array" do
    @a.categories.should be_an_instance_of(Array)
  end
  it "should have a start_date DateTime" do
    @a.start_date.should be_an_instance_of(DateTime)
  end
  it "should have a start_time DateTime" do
    @a.start_time.should be_an_instance_of(DateTime)
  end
  
end
