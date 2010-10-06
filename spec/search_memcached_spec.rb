require 'dalli'
require 'fake_web'
# Require the spec helper relative to this file
require File.join(File.dirname(__FILE__), %w[spec_helper])
require File.join(File.dirname(__FILE__), %w[custom_matchers_spec])
require File.join(File.dirname(__FILE__), %w[ .. lib services search])
require File.join(File.dirname(__FILE__), %w[ .. lib services activity])
include Active::Services

    
describe Search do
    after(:each) do
      begin
        Active.CACHE.flush() if Active.CACHE
      rescue Exception => e
      end
      Active.memcache_host(nil)
    end
    it "should search by city" do
      Active.memcache_host("localhost:11211")
      s = Search.search({:city=>"Oceanside"})
      s.city.should eql("Oceanside")
      s.results.should_not be_nil
      s.results.should have_at_least(1).items
      Active.CACHE.get('ce16c9ef2b618d0d5a88d46933109e4d').results.length.should eql(10)
      s = Search.search({:city=>"Oceanside"})
      s.city.should eql("Oceanside")
      s.results.should_not be_nil
      s.results.should have_at_least(1).items
    end
    it "should be fail safe" do
      Active.memcache_host("fake:11211")
      s = Search.search({:city=>"Oceanside"})
      s.city.should eql("Oceanside")      
      s.results.should have_at_least(1).items      
    end    
end





