require File.join(File.dirname(__FILE__), %w[spec_helper])
describe "Search" do
  describe "Asset" do
    
    describe "Instance Methods - Query Builder" do
    
      it "should build a query" do
        asset = Active::Query.new
        asset.to_query.should have_param("http://search.active.com/search?")
      end
      
      it "should have a facet in the query" do
        asset = Active::Query.new
        asset.facet = "activities"
        asset.to_query.should have_param("f=activities")
      end
      
      it "should specify sort and return itself" do
        asset = Active::Asset.sort(:date_desc)
        asset.should be_an_instance_of(Active::Query)
        asset.to_query.should have_param("s=date_desc")
        asset.sort(:relevance).should === asset
        asset.to_query.should have_param("s=relevance")
      end
      
      it "should specify order and return itself" do
        asset = Active::Asset.order(:date_asc)
        asset.should be_an_instance_of(Active::Query)
        asset.to_query.should have_param("s=date_asc")
        asset.order(:relevance).should === asset
        asset.to_query.should have_param("s=relevance")
      end

      it "should specify limit and return itself" do
        asset = Active::Asset.limit(5)
        asset.should be_an_instance_of(Active::Query)
        asset.to_query.should have_param("num=5")
        asset.limit(16).should === asset
        asset.to_query.should have_param("num=16")
        # alias per_page to limit
        asset.per_page(3).should === asset
        asset.to_query.should have_param("num=3")
      end
      
      it "should specify a per_page and return itself" do
        asset = Active::Asset.per_page(3)
        asset.should be_an_instance_of(Active::Query)
        asset.to_query.should have_param("num=3")
      end
      
      it "should raise an invalid option error" do
        lambda { Active::Asset.page(0) }.should raise_error(Active::InvalidOption)
        lambda { Active::Asset.page(-1) }.should raise_error(Active::InvalidOption)
      end
      
      it "should specify page and return itself" do
        asset = Active::Asset.page()
        asset.should be_an_instance_of(Active::Query)
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
        lambda { Active::Asset.find() }.should raise_error(Active::InvalidOption, "Couldn't find Asset without an ID")
      end

      it "should find record: Dean Karnazes Silicon Valley Marathon" do
        result = Active::Asset.find("DD8F427F-6188-465B-8C26-71BBA22D2DB7")
        result.should be_an_instance_of(Active::Asset)
      end

      it "should have two asset_id's in the query" do
        results = Active::Asset.find(["DD8F427F-6188-465B-8C26-71BBA22D2DB7", "2C384907-D683-4E83-BD97-63A46F38437A"])
        results.should be_an_instance_of(Array)
      end
      
      it "should throw an error if one or more asset_ids weren't found" do
        lambda { Active::Asset.find(["DD8F427F-6188-465B-8C26-71BBA22D2DB7", "123"])
        # }.should raise_error(Active::RecordNotFound)
        }.should raise_error(Active::RecordNotFound, "Couldn't find record with asset_id: 123")
      end
      
      describe "Result Object" do

        it "should have a title via dot notation" do
          result = Active::Asset.find("DD8F427F-6188-465B-8C26-71BBA22D2DB7")
          result.title.should eql("Dean Karnazes Silicon Valley Marathon | San Jose, California <b>...</b>")
        end
        
      end
      
      
    end
  
    describe "Results Object" do
      
      it "should find only 4 results" do
        asset = Active::Asset.order(:date_asc)
        asset.page(1)
        asset.limit(4)
        asset.order(:relevance)
        asset.should have_exactly(4).results
        asset.results.first.should be_an_instance_of(Active::Asset)
        asset.results.first.url.should_not be_nil
        asset.results.first.meta.eventId.should_not be_nil
        asset.results.first.meta.eventId.should eql("1920020")
      end
      
      
    end
  
  end
end
