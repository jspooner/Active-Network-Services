require File.join(File.dirname(__FILE__), %w[spec_helper])
describe "Search" do
  describe "Asset" do
    # describe HTTP and JSON Parse Errors
    
    describe "pagination" do
      it "should show the number of results" do
        asset = Active::Asset.location(:city=>"Oceanside")
        results = asset.results
        results.number_of_results.should_not be_nil
        results.end_index.should_not be_nil
        results.page_size.should_not be_nil
        results.search_time.should_not be_nil
      end
    end
    
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
        asset = Active::Asset.dma("San Francisco - Oakland - San Jose")
        asset.to_query.should have_param("meta:dma=San%2520Francisco%2520%252D%2520Oakland%2520%252D%2520San%2520Jose")
      end
      it "should place lat and lng in the l param" do
        asset = Active::Asset.near({:latitude=>"37.785895", :longitude=>"-122.40638", :radius => 25})
        asset.to_query.should have_param("l=37.785895,-122.40638")
        asset.to_query.should have_param("r=25")
      end
      it "should find by zip" do
        asset = Active::Activity.zip("92121")
        asset.to_query.should have_param("zip=92121")
        asset.results.each do |result|
          result.zip.should == "92121"
        end
      end
      it "should find many zips" do
        asset = Active::Activity.zips([92121, 92114])
        asset.to_query.should have_param("meta:zip=92121+OR+meta:zip=92114")
        asset.results.each do |result|
          result.zip.should satisfy do |zip|
            true if zip == "92121" or zip == "92114"
          end
        end

      end
      it "should construct a valid url with location" do
        asset = Active::Asset.location("San Diego, CA, US")
        asset.to_query.should have_param("l=San%20Diego%2C%20CA%2C%20US")
      end
      it "should construct a valid url with radius" do
        asset = Active::Asset.radius(50)
        asset.to_query.should have_param("r=50")
      end
      it "should send bounding_box" do
        pending
        asset = Active::Activity.bounding_box({ :sw => "33.007407,-117.332985", :ne => "33.179984,-117.003395"} )
        asset.to_query.should have_param("meta%253AlongitudeShifted%253A62.667015..62.996605")
        asset.to_query.should have_param("meta%253AlatitudeShifted%253A123.007407..123.179984")
        # asset.results.each do |result|
        #   puts "#{result.meta.latitude}, #{result.meta.longitude}<br/>"
        #   # result.meta.latitude.should satisfy do |lat|
        #   #   puts "<br/> latitude #{lat}"
        #   #   lat.to_f >= 33.007407 and lat.to_f <= 33.179984
        #   # end
        #   result.meta.longitude.should satisfy do |lng|
        #     puts "<br/> longitude #{lng.to_f}"
        #     lng.to_f <= -117.003395# and lng.to_f <= -117.332985
        #   end
        # end
      end
      it "should send bounding_box" do
        pending
        asset = Active::Activity.bounding_box({:ne=>"38.8643,-121.208199", :sw=>"36.893089,-123.533684"})
#puts asset.to_query
        asset.to_query.should have_param("meta%253AlatitudeShifted%253A126.893089..128.8643")
        asset.to_query.should have_param("meta%253AlongitudeShifted%253A56.466316..58.791801")
        # asset.results.each do |result|
        #   puts "#{result.meta.latitude}, #{result.meta.longitude}<br/>"
        #   # result.meta.latitude.should satisfy do |lat|
        #   #   puts "<br/> latitude #{lat}"
        #   #   lat.to_f >= 33.007407 and lat.to_f <= 33.179984
        #   # end
        #   result.meta.longitude.should satisfy do |lng|
        #     puts "<br/> longitude #{lng.to_f}"
        #     # lng.to_f <= -117.003395# and lng.to_f <= -117.332985
        #   end
        # end
      end
      
    end
    
    describe "Instance Methods - Query Builder - Meta" do
      it "should search keywords" do
        asset = Active::Asset.keywords('Running')
        asset.to_query.should have_param("k=Running")
        asset = Active::Asset.keywords(['Running', 'Hiking'])
        asset.to_query.should have_param("k=Running+Hiking")
      end
      it "should search channels" do
        asset = Active::Asset.channel('Running')
        asset.to_query.should have_param("meta:channel=Running")
      end
      it "should search splitMediaType" do
        asset = Active::Asset.splitMediaType('5k')
        asset.to_query.should have_param("meta:splitMediaType=5k")
        # open_url(asset.to_query)
      end
    end
    
    describe "Instance Methods - Query Builder - Dates" do
      it "should send a valid start and end date" do
        sd = Date.new(2011, 11, 1)
        ed = Date.new(2011, 11, 3)
        asset = Active::Asset.date_range( sd, ed ) 
        asset.should be_an_instance_of(Active::Query)
        asset.to_query.should have_param("meta:startDate:daterange:11%2F01%2F2011..11%2F03%2F2011")
        asset.results.size.should eq(10)
        asset.results.each do |result|
          result.meta.startDate.should satisfy { |date| 
            d = Date.parse(date)
            d >= sd and d <= ed 
          }
        end
      end
      it "should send a valid start and end date" do
        asset = Active::Asset.date_range( "2011-11-1", "2011-11-3" )
        asset.should be_an_instance_of(Active::Query)
        asset.to_query.should have_param("meta:startDate:daterange:11%2F01%2F2011..11%2F03%2F2011")
        asset.results.size.should eq(10)
        asset.results.each do |result|
          result.meta.startDate.should satisfy { |date| 
            d = Date.parse(date)
            d >= Date.parse("2011-11-1") and d <= Date.parse("2011-11-3")
          }
        end
      end
      it "should send a valid start and end date" do
        asset = Active::Asset.date_range( "1/11/2011", "3/11/2011" )
        asset.should be_an_instance_of(Active::Query)
        asset.to_query.should have_param("meta:startDate:daterange:11%2F01%2F2011..11%2F03%2F2011")
        asset.results.size.should eq(10)
        asset.results.each do |result|
          result.meta.startDate.should satisfy { |date| 
            d = Date.parse(date)
            d >= Date.parse("2011-11-1") and d <= Date.parse("2011-11-3")
          }
        end
      end
      
      
      
      it "should search past" do
        asset = Active::Asset.past
        asset.should be_an_instance_of(Active::Query)
        asset.to_query.should have_param("meta:startDate:daterange:..#{Date.today}")
        asset.results.each do |result|
          result.meta.startDate.should satisfy { |date| 
            Date.parse(date) <= Date.today
          }
        end
      end
      it "should search future" do
        asset = Active::Asset.future
        asset.should be_an_instance_of(Active::Query)
        asset.to_query.should have_param("daterange:today..+")
        asset.results.each do |result|
          result.meta.startDate.should satisfy { |date| 
            Date.parse(date) >= Date.today
          }
        end
      end
      it "should search today" do
        asset = Active::Asset.today
        asset.should be_an_instance_of(Active::Query)        
        asset.to_query.should have_param("meta:startDate:#{Date.today}")
        asset.results.each do |result|
          result.meta.startDate.should satisfy { |date| 
            Date.parse(date) == Date.today
          }
        end
      end
      
    end
    
    describe "Instance Methods - Catching empty and nill values" do
      it "should not pass empty values" do
        asset = Active::Activity.page(1).limit(10)
        asset.keywords("")
        asset.state("")
        asset.channel("Running")
        asset.to_query.should_not have_param("meta:state=")
        asset.to_query.should_not have_param("k=")
        asset.to_query.should have_param("meta:channel=Running")
        asset.to_query.should_not have_param("+OR++OR+")
        asset.to_query.should_not have_param("+AND++AND+")
      end
      it "should not pass nil values" do
        asset = Active::Activity.page(1).limit(10)
        asset.keywords("")
        asset.state(nil)
        asset.channel("Running")
        asset.to_query.should_not have_param("meta:state=")        
      end
    end
    
    describe "Static Find Methods" do
      it "should raise error if no id is specified" do
        lambda { Active::Asset.find() }.should raise_error(Active::InvalidOption, "Couldn't find Asset without an ID")
      end
      it "should find record: Dean Karnazes Silicon Valley Marathon" do
        result = Active::Asset.find("DD8F427F-6188-465B-8C26-71BBA22D2DB7")
        result.should be_an_instance_of(Active::Asset)
        result.asset_id.should eql("DD8F427F-6188-465B-8C26-71BBA22D2DB7")
      end
      it "should have two asset_id's in the query" do
        results = Active::Asset.find(["DD8F427F-6188-465B-8C26-71BBA22D2DB7", "2C384907-D683-4E83-BD97-63A46F38437A"])
        results.should be_an_instance_of(Array)
      end
      it "should throw an error if one or more asset_ids weren't found" do
        lambda { Active::Asset.find(["DD8F427F-6188-465B-8C26-71BBA22D2DB7", "123"])
        }.should raise_error(Active::RecordNotFound, "Couldn't find record with asset_id: 123")
      end
      it "should find a record by url" do
        # event = Active::Activity.find_by_url("http://www.active.com/triathlon/oceanside-ca/rohto-ironman-703-california-2011")
        event = Active::Activity.find_by_url("www.active.com/triathlon/oceanside-ca/rohto-ironman-703-california-2011")
        event.title.should eql("2011 Rohto Ironman 70.3 California")
      end
      describe "Result Object" do
        it "should have a title via dot notation" do
          result = Active::Asset.find("DD8F427F-6188-465B-8C26-71BBA22D2DB7")
          result.title.should eql("Dean Karnazes Silicon Valley Marathon")
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
      end
      
      it "should find Running events" do
        asset = Active::Asset.order(:date_asc)
        asset.page(1).limit(1)
        asset.channel('Running')
        asset.to_query.should have_param('Running')
        asset.results.first.should be_an_instance_of(Active::Activity)
        asset.results.first.url.should_not be_nil
        asset.results.first.meta.eventId.should_not be_nil
      end
      
      it "should not return more then 1000 results" do
        # GSA will only return 1000 events but will give us a number larger then 1000.
        # This test depends on this query returning more than 1000 
        asset = Active::Asset.order(:date_asc)
        asset.results.number_of_results.should eql(1000)
      end
    end
  
    describe "Results Object" do
      
      it "should have a date object for each result" do
        asset = Active::Asset.new({"meta" => {"startDate"=>"2011-07-16"}})
        asset.start_date.should be_an_instance_of(Date)
      end
            
      it "should return nil of there isn't a date" do
        asset = Active::Asset.new()
        asset.start_date.should be_nil
        asset = Active::Asset.new({"meta" => { "foo"=>"bar" }})
        asset.start_date.should be_nil
      end
      
      it "should return nil if the title is missing" do
        asset = Active::Asset.new({"meta" => {"startDate"=>"2011-07-16"}})
        asset.title.should be_nil
      end

      it "should return nil if the title is missing" do
        asset = Active::Asset.new({"meta" => {"startDate"=>"2011-07-16"}})
        asset.to_json.should eql("{\"meta\":{\"startDate\":\"2011-07-16\"}}")
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
    
    describe "Real world examples" do
      it "should work in Search.rb" do
        asset = Active::Activity.page(1).limit(10)
        asset.date_range( "2000-11-1", "2011-11-3" )
        asset.keywords("run")
        asset.state("CA")                          
        asset.channel("Running")                   
        
        asset.to_query.should have_param("meta:startDate:daterange:11%2F01%2F2000..11%2F03%2F2011")
        asset.to_query.should have_param("k=run")
        asset.to_query.should have_param("meta:state=CA")
        asset.to_query.should have_param("meta:channel=Running")    
        
        # open_url asset.to_query
        asset.should have_exactly(10).results    
      end
      it "should work in Search.rb" do
        asset = Active::Activity.page(1).limit(10)
        asset.date_range( "2000-11-1", "2011-11-3" )
        asset.keywords("run walk")
        asset.state("CA")                          
        asset.channel("Running")                   

        # open_url asset.to_query        
        asset.to_query.should have_param("k=run%20walk")
        asset.should have_at_least(1).results    
      end
    end
    
    describe "invalid UTF-8 byte sequences" do
      it "should gracefully handle invalid UTF-8 byte sequences in the title" do
        asset = Active::Asset.new()
        asset['title'] = "one | \xB7 two"
        asset.title.should eql("one")
      end
    end
    
    describe "HTML and special character sanitizing" do
      it "should convert HTML special characters in the title" do
        asset = Active::Asset.new()
        asset['title'] = "one &amp; two"
        asset.title.should eql("one & two")
      end
      it "should remove HTML tags from the title" do
        asset = Active::Asset.new()
        asset['title'] = "one <b>two</b>"
        asset.title.should eql("one two")
      end
      it "should remove HTML tags from the description" do
        asset = Active::Asset.new({"meta" => { "summary"=>"one <b>two</b>" }})
        asset.description.should eql("one two")
      end
    end
    
  end
end
