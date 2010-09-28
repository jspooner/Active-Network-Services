# Require the spec helper relative to this file
require File.join(File.dirname(__FILE__), %w[spec_helper])
require File.join(File.dirname(__FILE__), %w[custom_matchers_spec])
require File.join(File.dirname(__FILE__), %w[ .. lib services search])
require File.join(File.dirname(__FILE__), %w[ .. lib services activity])
include Active
include Active::Services


describe Active do

  it "shouls set memcache" do
    Active.CACHE.should be_nil
    Active.memcache_host "localhost:11211"
    Active.CACHE.should_not be_nil    
  end
  
  it "should have a working memcache" do
    Active.memcache_host "localhost:11211"
    Active.CACHE.set("active","rocks");
    Active.CACHE.get("active").should eql("rocks")
  end
  
  it "should cache the data" do
    Active.memcache_host "localhost:11211"
  end
  
end

