# Require the spec helper relative to this file
require File.join(File.dirname(__FILE__), %w[spec_helper])
# require File.join(File.dirname(__FILE__), %w[custom_matchers_spec])

describe "Search" do
  describe "Base" do    
  
    # before(:each) do
    #   @base = Active::Base.new
    # end
  
    it "should have a facet accessor" do
      Active::Base.new.facet.should be_nil  
      base = Active::Base.new(:facet => "foo")
      base.facet.should eql("foo")
    end
    
    describe "Instance Methods - Query Builder" do
    
      it "should build a query" do
        base = Active::Base.new
        base.to_query.should have_param("http://search.active.com/search?")
      end
    
      it "should raise error if no id is specified" do
        lambda { Active::Base.find() }.should raise_error(Active::RecordNotFound)
      end

      it "should find record 666" do
        pending "Need to load the real object"
        result = Active::Base.find("666")
        result.should be_an_instance_of(Object)
      end

      it "should have two asset_id's in the query" do
        pending "Need to load the real object"        
        results = Active::Base.find(["123456", "666"])
        results.should be_an_instance_of(Array) 
      end
      
      it "should have a facet in the query" do
        base = Active::Base.new
        base.facet = "activities"
        base.to_query.should have_param("f=activities")
      end
      
      it "should specify sort and return itself" do
        base = Active::Base.sort(:date_desc)
        base.should be_an_instance_of(Active::Base)
        base.to_query.should have_param("s=date_desc")
        base.sort(:relevance).should === base
        base.to_query.should have_param("s=relevance")
      end
      
      it "should specify order and return itself" do
        base = Active::Base.order(:date_asc)
        base.should be_an_instance_of(Active::Base)
        base.to_query.should have_param("s=date_asc")
        base.order(:relevance).should === base
        base.to_query.should have_param("s=relevance")
      end

      it "should specify limit and return itself" do
        base = Active::Base.limit(5)
        base.should be_an_instance_of(Active::Base)
        base.to_query.should have_param("num=5")
        base.limit(16).should === base
        base.to_query.should have_param("num=16")
        # alias per_page to limit
        base.per_page(3).should === base
        base.to_query.should have_param("num=3")
      end
      
      it "should specify a per_page and return itself" do
        base = Active::Base.per_page(3)
        base.should be_an_instance_of(Active::Base)
        base.to_query.should have_param("num=3")
      end
      
      it "should raise an invalid option error" do
        lambda { Active::Base.page(0) }.should raise_error(Active::InvalidOption)
        lambda { Active::Base.page(-1) }.should raise_error(Active::InvalidOption)
      end
      
      it "should specify page and return itself" do
        base = Active::Base.page()
        base.should be_an_instance_of(Active::Base)
        base.to_query.should have_param("page=1")
        base.page(5).should === base
        base.to_query.should have_param("page=5")
      end
      
      it "does something" do
        base = Active::Base.page(2).limit(5).sort(:date_asc)
        base.to_query.should have_param("page=2")
        base.to_query.should have_param("s=date_asc")
        base.to_query.should have_param("num=5")
      end
      
    end
    
    
  end
end
