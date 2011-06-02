# Require the spec helper relative to this file
require File.join(File.dirname(__FILE__), %w[spec_helper])
# require File.join(File.dirname(__FILE__), %w[custom_matchers_spec])

describe "Search" do
  describe "Asset" do
  
    # before(:each) do
    #   @asset = Active::Asset.new
    # end
  
    it "should have a facet accessor" do
      Active::Asset.new.facet.should be_nil
      asset = Active::Asset.new
      asset.facet = "foo"
      asset.facet.should eql("foo")
    end
    
    describe "Instance Methods - Query Builder" do
    
      it "should build a query" do
        asset = Active::Asset.new
        asset.to_query.should have_param("http://search.active.com/search?")
      end
      
      it "should have a facet in the query" do
        asset = Active::Asset.new
        asset.facet = "activities"
        asset.to_query.should have_param("f=activities")
      end
      
      it "should specify sort and return itself" do
        asset = Active::Asset.sort(:date_desc)
        asset.should be_an_instance_of(Active::Asset)
        asset.to_query.should have_param("s=date_desc")
        asset.sort(:relevance).should === asset
        asset.to_query.should have_param("s=relevance")
      end
      
      it "should specify order and return itself" do
        asset = Active::Asset.order(:date_asc)
        asset.should be_an_instance_of(Active::Asset)
        asset.to_query.should have_param("s=date_asc")
        asset.order(:relevance).should === asset
        asset.to_query.should have_param("s=relevance")
      end

      it "should specify limit and return itself" do
        asset = Active::Asset.limit(5)
        asset.should be_an_instance_of(Active::Asset)
        asset.to_query.should have_param("num=5")
        asset.limit(16).should === asset
        asset.to_query.should have_param("num=16")
        # alias per_page to limit
        asset.per_page(3).should === asset
        asset.to_query.should have_param("num=3")
      end
      
      it "should specify a per_page and return itself" do
        asset = Active::Asset.per_page(3)
        asset.should be_an_instance_of(Active::Asset)
        asset.to_query.should have_param("num=3")
      end
      
      it "should raise an invalid option error" do
        lambda { Active::Asset.page(0) }.should raise_error(Active::InvalidOption)
        lambda { Active::Asset.page(-1) }.should raise_error(Active::InvalidOption)
      end
      
      it "should specify page and return itself" do
        asset = Active::Asset.page()
        asset.should be_an_instance_of(Active::Asset)
        asset.to_query.should have_param("page=1")
        asset.page(5).should === asset
        asset.to_query.should have_param("page=5")
      end
      
      it "does something" do
        asset = Active::Asset.page(2).limit(5).sort(:date_asc)
        asset.to_query.should have_param("page=2")
        asset.to_query.should have_param("s=date_asc")
        asset.to_query.should have_param("num=5")
      end
      
    end
    
    describe "Static Find Methods" do
      it "should raise error if no id is specified" do
        lambda { Active::Asset.find() }.should raise_error(Active::RecordNotFound)
      end

      it "should find record: Dean Karnazes Silicon Valley Marathon" do
        # pending "Need to load the real object"
        result = Active::Asset.find("DD8F427F-6188-465B-8C26-71BBA22D2DB7")
        result.should be_an_instance_of(Active::Asset)
      end

      it "should have two asset_id's in the query" do
        results = Active::Asset.find(["DD8F427F-6188-465B-8C26-71BBA22D2DB7", "2C384907-D683-4E83-BD97-63A46F38437A"])
        results.should be_an_instance_of(Array)
      end
    end
  end
end
