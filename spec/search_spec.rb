require 'fake_web'
# Require the spec helper relative to this file
require File.join(File.dirname(__FILE__), %w[spec_helper])
require File.join(File.dirname(__FILE__), %w[ .. lib services search])
require File.join(File.dirname(__FILE__), %w[ .. lib services activity])

# No need to type Britify:: before each call
include Active::Services

describe  "Set up" do
  it "should set the api key"
  it "should not all search.active.com by default"
  it "should call search.active.com when told to"
end

describe  "Search URL Construction" do

  it "should construct a valid url with location" do
    url = Search.construct_url( {:location => "San Diego, CA, US"} )
    uri = URI.parse(url)
    uri.scheme.should eql("http")
    uri.host.should eql("search.active.com")
    uri.query.include?("l=#{CGI.escape("San Diego, CA, US")}").should be_true
  end
  
  it "should construct a valid url from a zip code" do
    uri = URI.parse(Search.construct_url( {:zip => "92121"} ))    
    uri.query.include?("l=#{CGI.escape("92121")}").should be_true
  end
  
  it "should construct a valid url with CSV keywords" do
    uri = URI.parse( Search.construct_url( {:keywords => "running, tri"} ) )
    uri.query.include?("k=running+tri").should be_true
  end
  
  it "should construct a valid url with keywords array" do
    uri = URI.parse( Search.construct_url( {:keywords => ["running","tri","cycling"]} ) )
    uri.query.include?("k=running+tri+cycling").should be_true
  end
  
  it "should have defaults set" do
    uri = URI.parse( Search.construct_url() )
    uri.query.include?("f=#{Facet.ACTIVITIES}").should be_true    
    uri.query.include?("s=#{Sort.DATE_ASC}").should be_true    
    uri.query.include?("r=10").should be_true    
    uri.query.include?("v=json").should be_true    
    uri.query.include?("page=1").should be_true    
    uri.query.include?("num=10").should be_true    
    uri.query.include?("daterange:today..+").should be_true            
  end
  
  it "should send valid channel info" do
    uri = URI.parse( Search.construct_url({:channels => ['Running','Triathlon']}) )
    uri.query.include?("meta:channel=Running+OR+meta:channel=Triathlon").should be_true            
  end
  
  it "should send a valid start and end date" do
    uri = URI.parse( Search.construct_url() )    
    uri.query.include?("daterange:today..+").should be_true            
  end

  it "should send a valid start and end date" do
    uri = URI.parse( Search.construct_url({:start_date => Date.new(2010, 11, 1), :end_date => Date.new(2010, 11, 15)}) )    
    uri.query.include?("meta:startDate:daterange:11%2F01%2F2010..11%2F15%2F2010").should be_true                
  end
  
  it "should be valid with date range and channels" do
    uri = URI.parse( Search.construct_url({:channels => ['Running','Triathlon'],
                                           :start_date => Date.new(2010, 11, 1), 
                                           :end_date => Date.new(2010, 11, 15)}) )
    uri.query.include?("meta:channel=Running+OR+meta:channel=Triathlon").should be_true            
    uri.query.include?("daterange:11%2F01%2F2010..11%2F15%2F2010").should be_true                    
  end
  
end


describe Search do
  after(:each) do 
    FakeWeb.clean_registry
  end
  
  it "should have some channels" do
    Search.CHANNELS.should_not be_nil
  end
  
  it "should raise and error during a 404" do
    FakeWeb.register_uri(:get, "http://search.active.com/search?api_key=&num=10&page=1&l=San+Diego%2C+CA%2C+US&f=activities&v=json&r=10&s=date_asc&k=&m=meta:startDate:daterange:today..+", 
                         :body => "Nothing to be found 'round here", :status => ["404", "Not Found"])
    lambda { Search.search( {:location => "San Diego, CA, US"} ) }.should raise_error(RuntimeError)                         
  end
  
  it "should search by location (san diego)" do
    FakeWeb.register_uri(:get, "http://search.active.com/search?api_key=&num=10&page=1&l=San+Diego%2C+CA%2C+US&f=activities&v=json&r=10&s=date_asc&k=&m=meta:startDate:daterange:today..+", 
                         :body => '{"endIndex":5,"numberOfResults":2,"pageSize":5,"searchTime":0.600205,"_results":[{"escapedUrl": "http://www.active.com/running/calabasas-ca/calabasas-classic-5k-10k-runs-2010","language": "en","title": "Calabasas Classic 2010 - 5k \u003cb\u003e10k\u003c/b\u003e Runs | Calabasas, California 91302 \u003cb\u003e...\u003c/b\u003e","url": "http://www.active.com/running/calabasas-ca/calabasas-classic-5k-10k-runs-2010","summary": "\u003cb\u003e...\u003c/b\u003e Calabasas Classic 2010 - 5k \u003cb\u003e10k\u003c/b\u003e Runs. Based on 0 reviews. \u003cb\u003e...\u003c/b\u003e Recent Reviews Calabasas\u003cbr\u003e Classic 2010 - 5k \u003cb\u003e10k\u003c/b\u003e Runs reviews. Get Directions. Start Address. End Address \u003cb\u003e...\u003c/b\u003e  ","meta": {"startDate": "2010-11-14","eventDate": "2010-11-14T08:00:00-08:00","location": "Calabasas Park Centre","tag": ["event:10", "Green:10", "Running:10"],"state": "California","eventLongitude": "-118.6789","endDate": "2010-11-14","locationName": "Calabasas Park Centre","splitMediaType": ["Event", "1 mile", "10K", "5K"],"endTime": "8:00:00","mediaType": ["Event", "Event\\1 mile", "Event\\10K", "Event\\5K"],"google-site-verification": "","city": "Calabasas","startTime": "8:00:00","assetId": ["11B01475-8C65-4F9C-A4AC-2A3FA55FE8CD", "11b01475-8c65-4f9c-a4ac-2a3fa55fe8cd"],"eventId": "1810531","participationCriteria": "All","description": "","longitude": "-118.6789","onlineDonationAvailable": "false","substitutionUrl": "1810531","assetName": ["Calabasas Classic 2010 -  5k 10k Runs", "Calabasas Classic 2010 -  5k 10k Runs"],"zip": "91302","contactPhone": "818-715-0428","sortDate": "2000-11-14","eventState": "California","eventLatitude": "34.12794","keywords": "Event","eventAddress": "23975 Park Sorrento","contactEmail": "rot10kd@yahoo.com","onlineMembershipAvailable": "false","trackbackurl": "http://www.active.com/running/calabasas-ca/calabasas-classic-5k-10k-runs-2010","country": "United States","onlineRegistrationAvailable": "true","category": "Activities","image1": "http://www.active.com/images/events/hotrace.gif","assetTypeId": "EA4E860A-9DCD-4DAA-A7CA-4A77AD194F65","lastModifiedDate": "2010-03-04 07:30:26.307","eventZip": "91302","latitude": "34.12794","UpdateDateTime": "8/18/2010 10:16:26 AM","channel": ["Running", "Walking"]}},
                         {"escapedUrl": "http://www.active.com/10k-race/seattle-wa/fitness-for-vitality-5k10k-3race-series-919-2010","language": "en","title": "Fitness For Vitality 5k/\u003cb\u003e10k\u003c/b\u003e 3-Race Series (9/19, 10/17, 11/21) \u003cb\u003e...\u003c/b\u003e","url": "http://www.active.com/10k-race/seattle-wa/fitness-for-vitality-5k10k-3race-series-919-2010","summary": "\u003cb\u003e...\u003c/b\u003e Fitness For Vitality 5k/\u003cb\u003e10k\u003c/b\u003e 3-Race Series (9/19, 10/17, 11/21). Based on 0 reviews. \u003cb\u003e...\u003c/b\u003e\u003cbr\u003e Reviews of Fitness For Vitality 5k/\u003cb\u003e10k\u003c/b\u003e 3-Race Series (9/19, 10. \u003cb\u003e...\u003c/b\u003e  ","meta": {"summary": "\u003cp style\u003dtext-align:left\u003e\u003cfont style\u003dfont-family:UniversEmbedded;font-size:12;color:#000000; LETTERSPACING\u003d0 KERNING\u003d0\u003eRace or walk on a flat, fast, and fun course! The entire event is along the Puget Sound. Do all 3 events in the series and watch your time and fitness improve! Oatmeal post-race. 10% proceeds sh","startDate": "2010-09-19","eventDate": "2010-09-19","location": "Alki Beach Park, Seattle","tag": ["event:10", "Running:10"],"state": "Washington","endDate": "2010-11-22","locationName": "1702 Alki Ave. SW","splitMediaType": ["5K", "difficulty:Beginner", "difficulty:Advanced", "Event", "difficulty:Intermediate", "10K"],"lastModifiedDateTime": "2010-08-19 23:35:50.117","endTime": "07:59:59","mediaType": ["5K", "difficulty:Beginner", "difficulty:Advanced", "Event", "difficulty:Intermediate", "10K"],"google-site-verification": "","city": "Seattle","startTime": "07:00:00","assetId": ["39e8177e-dd0e-42a2-8a2b-24055e5325f3", "39e8177e-dd0e-42a2-8a2b-24055e5325f3"],"eventId": "E-000NGFS9","participationCriteria": "Kids,Family","description": "","longitude": "-122.3912","substitutionUrl": "E-000NGFS9","assetName": ["Fitness For Vitality 5k/10k 3-Race Series (9/19, 10/17, 11/21)", "Fitness For Vitality 5k/10k 3-Race Series (9/19, 10/17, 11/21)"],"zip": "98136","contactPhone": "n/a","eventState": "WA","sortDate": "2000-09-19","keywords": "Event","eventAddress": "1702 Alki Ave. SW","contactEmail": "n/a","dma": "Seattle - Tacoma","trackbackurl": "http://www.active.com/10k-race/seattle-wa/fitness-for-vitality-5k10k-3race-series-919-2010","seourl": "http://www.active.com/10k-race/seattle-wa/fitness-for-vitality-5k10k-3race-series-919-2010","country": "United States","onlineRegistrationAvailable": "true","category": "Activities","image1": "http://photos-images.active.com/file/3/1/optimized/9015e50d-3a2e-4ce4-9ddc-80b05b973b01.jpg","allText": "\u003cp style\u003dtext-align:left\u003e\u003cfont style\u003dfont-family:UniversEmbedded;font-size:12;color:#000000; LETTERSPACING\u003d0 KERNING\u003d0\u003eRace or walk on a flat, fast, and fun course! The entire event is along the Puget Sound. Do all 3 events in the series and watch your time and fitness improve! Oatmeal post-race. 10% proceeds sh","address": "1702 Alki Ave. SW","assetTypeId": "DFAA997A-D591-44CA-9FB7-BF4A4C8984F1","lastModifiedDate": "2010-08-19","eventZip": "98136","latitude": "47.53782","UpdateDateTime": "8/18/2010 10:16:08 AM","channel": "Running"}},
                         {"escapedUrl": "http://www.active.com/running/calabasas-ca/calabasas-classic-5k-10k-runs-2010","language": "en","title": "Calabasas Classic 2010 - 5k \u003cb\u003e10k\u003c/b\u003e Runs | Calabasas, California 91302 \u003cb\u003e...\u003c/b\u003e","url": "http://www.active.com/running/calabasas-ca/calabasas-classic-5k-10k-runs-2010","summary": "\u003cb\u003e...\u003c/b\u003e Calabasas Classic 2010 - 5k \u003cb\u003e10k\u003c/b\u003e Runs. Based on 0 reviews. \u003cb\u003e...\u003c/b\u003e Recent Reviews Calabasas\u003cbr\u003e Classic 2010 - 5k \u003cb\u003e10k\u003c/b\u003e Runs reviews. Get Directions. Start Address. End Address \u003cb\u003e...\u003c/b\u003e  ","meta": {"startDate": "2010-11-14","eventDate": "2010-11-14T08:00:00-08:00","location": "Calabasas Park Centre","tag": ["event:10", "Green:10", "Running:10"],"state": "California","eventLongitude": "-118.6789","endDate": "2010-11-14","locationName": "Calabasas Park Centre","splitMediaType": ["Event", "1 mile", "10K", "5K"],"endTime": "8:00:00","mediaType": ["Event", "Event\\1 mile", "Event\\10K", "Event\\5K"],"google-site-verification": "","city": "Calabasas","startTime": "8:00:00","assetId": ["11B01475-8C65-4F9C-A4AC-2A3FA55FE8CD", "11b01475-8c65-4f9c-a4ac-2a3fa55fe8cd"],"eventId": "1810531","participationCriteria": "All","description": "","longitude": "-118.6789","onlineDonationAvailable": "false","substitutionUrl": "1810531","assetName": ["Calabasas Classic 2010 -  5k 10k Runs", "Calabasas Classic 2010 -  5k 10k Runs"],"zip": "91302","contactPhone": "818-715-0428","sortDate": "2000-11-14","eventState": "California","eventLatitude": "34.12794","keywords": "Event","eventAddress": "23975 Park Sorrento","contactEmail": "rot10kd@yahoo.com","onlineMembershipAvailable": "false","trackbackurl": "http://www.active.com/running/calabasas-ca/calabasas-classic-5k-10k-runs-2010","country": "United States","onlineRegistrationAvailable": "true","category": "Activities","image1": "http://www.active.com/images/events/hotrace.gif","assetTypeId": "EA4E860A-9DCD-4DAA-A7CA-4A77AD194F65","lastModifiedDate": "2010-03-04 07:30:26.307","eventZip": "91302","latitude": "34.12794","UpdateDateTime": "8/18/2010 10:16:26 AM","channel": ["Running", "Walking"]}}]}',
                         :status => ["200", "Found"])
    results = Search.search( {:location => "San Diego, CA, US"} )
    results.should have(3).items
    results.each do |a|
      a.should be_an_instance_of(Activity)
      a.title.should_not be_nil
      a.start_date.should_not be_nil
      a.end_date.should_not be_nil
      a.category.should_not be_nil
      a.desc.should_not be_nil
      a.start_time.should_not be_nil
      a.end_time.should_not be_nil
      a.address.should_not be_nil      
      a.address[:name].should_not be_nil      
      a.address[:city].should_not be_nil      
      a.address[:state].should_not be_nil      
      a.address[:zip].should_not be_nil      
      a.address[:country].should_not be_nil      
      a.address[:lat].should_not be_nil      
      a.address[:lng].should_not be_nil      
    end
  end

end

describe "Call Live Data" do
  it "should find only events in the future" do
    results = Search.search( {} )
    results.should have(10).items
    results.each do |a|
      a.start_date.should satisfy { |d|
        d >= Date.today
      }
    end
  end

  it "should find only events with in a range" do
    results = Search.search( {:start_date => Date.new(2010,1,1), :end_date => Date.new(2010,2,1)} )
    results.should have(10).items
    results.each do |a|
      a.start_date.should satisfy { |d|
        d >= Date.new(2010,1,1) and d <= Date.new(2010,2,1)
      }
    end
  end

  it "should find events after the start date" do
    results = Search.search( {:start_date => Date.new(2010,1,1), :num_results => 50} )
    results.should have(50).items
    results.each do |a|
      a.start_date.should satisfy { |d|
        d >= Date.new(2010,1,1) 
      }
    end
  end
  
  it "should find only running activities" do
    results = Search.search( {:channels => ['Running'],
                              :start_date => Date.new(2010,1,1), :num_results => 20} )
    results.should have(20).items    
    results.each do |a|
      puts "-#{a.category}-"
      a.category.should satisfy { |d|
        d.include?('Running' )
      }
    end
    
    
  end
  
  it "should find activities that have been recently added" 
  
  it "should find upcoming events"
  
  it "should find popular events"
  
  it "should order by trending with params"
  #   results = Search.search( {:channels => ['Running'], :sort => 'trending'} )
  # end
  
  it "should order by RELEVANCE"
  
  it "should order by date DATE_ASC"

  it "should order by date DATE_DESC"
  
end
