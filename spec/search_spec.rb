require File.join(File.dirname(__FILE__), %w[spec_helper])
describe "Search" do
  describe "Asset" do
    
    describe "Instance Methods - Query Builder - Default Options" do
      it "should build a query" do
        asset = Active::Query.new
        asset.to_query.should have_param("http://search.active.com/search?")
      end
      it "should have a facet in the query" do
        asset = Active::Query.new(:facet => 'activities')
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
    
    describe "Instance Methods - Query Builder - Location" do
      it "should search by city" do
        asset = Active::Asset.location(:city=>"Oceanside")
        asset.to_query.should have_param("meta:city=Oceanside")
      end
      it "should double encode the city" do
        asset = Active::Asset.city("San Marcos")
        asset.to_query.should have_param("meta:city=San%2520Marcos")
        
        asset = Active::Asset.location(:city=>"San Marcos")
        asset.to_query.should have_param("meta:city=San%2520Marcos")
      end
      it "should pass California as the meta state" do
        asset = Active::Asset.state("California")
        asset.to_query.should have_param("meta:state=California")

        asset = Active::Asset.state(["California", "Oregon"])
        asset.to_query.should have_param("meta:state=California+OR+meta:state=Oregon")
        
        asset = Active::Asset.location(:state=>"California")
        asset.to_query.should have_param("meta:state=California")
      end
      it "should search by the SF DMA" do
        asset = Active::Asset.location(:dma=>"San Francisco - Oakland - San Jose")
        asset.to_query.should have_param("meta:dma=San%2520Francisco%2520%252D%2520Oakland%2520%252D%2520San%2520Jose")
      end
      it "should place lat and lng in the l param" do
        asset = Active::Asset.near({:latitude=>"37.785895", :longitude=>"-122.40638", :radius => 25})
        asset.to_query.should have_param("l=37.785895;-122.40638")
        asset.to_query.should have_param("r=25")
      end
      it "should send an array of zips" do
        asset = Active::Asset.location(:zips => [92121, 92078, 92114])
        asset.to_query.should have_param("l=92121,92078,92114")
      end
      it "should construct a valid url with location" do
        asset = Active::Asset.location(:location => "San Diego, CA, US")
        asset.to_query.should have_param("l=#{CGI.escape("San Diego, CA, US")}")
      end
      it "should send valid channel info and a bounding_box" do
        asset = Active::Asset.location( :bounding_box => { :sw => "37.695141,-123.013657", :ne => "37.695141,-123.013657"} )
        asset.to_query.should have_param("meta:latitudeShifted:127.695141..127.695141+AND+meta:longitudeShifted:56.986343..56.986343")
      end
    end
    
    describe "Instance Methods - Query Builder - Meta" do
      # Keywords
      # channels
      # split media types
    end
    
    describe "Instance Methods - Query Builder - Dates" do
      it "should send a valid start and end date" do
        asset = Active::Asset.date({ :start_date => Date.new(2010, 11, 1), :end_date => Date.new(2010, 11, 15) })
        asset.to_query.should have_param("meta:startDate:daterange:11%2F01%2F2010..11%2F15%2F2010")
      end
      it "should search past" do
        pending
        asset = Active::Asset.date
        asset.to_query.should have_param("meta:startDate:daterange:11%2F01%2F2010..11%2F15%2F2010")
      end
      it "should search future" do
        pending
        asset = Active::Asset.date
        asset.to_query.should have_param("meta:startDate:daterange:11%2F01%2F2010..11%2F15%2F2010")
      end
      it "should search today" do
        pending
        asset = Active::Asset.date
        asset.to_query.should have_param("meta:startDate:daterange:11%2F01%2F2010..11%2F15%2F2010")
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
        asset = Active::Asset.order(:relevance)
        asset.page(1)
        asset.limit(4)
        asset.order(:date_asc)
        asset.should have_exactly(4).results
        asset.results.first.should be_an_instance_of(Active::Activity)
        asset.results.first.url.should_not be_nil
        asset.results.first.meta.eventId.should_not be_nil
        asset.results.first.meta.eventId.should eql("1735298")
      end
      
      it "should find Running events" do
        asset = Active::Asset.order(:date_asc)
        asset.page(1).limit(1)
        asset.channel('Running')
        asset.to_query.should have_param('Running')
        asset.results.first.should be_an_instance_of(Active::Activity)
        asset.results.first.url.should_not be_nil
        asset.results.first.meta.eventId.should_not be_nil
        # asset.results.first.meta.eventId.should eql("1520568")
      end
    end
    
    describe "Factory" do
      it "should type cast results" do
        asset = Active::Asset.factory({})
        asset.should be_an_instance_of(Active::Asset)
        asset2 = Active::Asset.factory({'meta'=>{'category'=>'Activities'}})
        asset2.should be_an_instance_of(Active::Activity)
        asset3 = Active::Asset.factory({'meta'=>{'category'=>'Articles'}})
        asset3.should be_an_instance_of(Active::Article)
        asset4 = Active::Asset.factory({'meta'=>{'category'=>'Training plans'}})
        asset4.should be_an_instance_of(Active::Training)
      end
    end
  
  end
  
  
end
