require 'fake_web'
# Require the spec helper relative to this file
require File.join(File.dirname(__FILE__), %w[spec_helper])
require File.join(File.dirname(__FILE__), %w[custom_matchers_spec])
require File.join(File.dirname(__FILE__), %w[ .. lib services search])
require File.join(File.dirname(__FILE__), %w[ .. lib services activity])
include Active::Services

describe  "Set up" do
  it "should set the api key"
  it "should not all search.active.com by default"
  it "should call search.active.com when told to"
end

describe  "Search URL Construction" do
  include CustomMatchers
  it "should escape the location" do
    s = Search.new()
    s.location.should eql("")
    s = Search.new({:location => "San Diego"})
    s.location.should eql("San+Diego")
  end
  
  it "should have an array of keywords" do
    s = Search.new()
    s.should have(0).keywords
    s = Search.new({:keywords => "Dog,Cat,Cow"})
    s.should have(3).keywords
    s = Search.new({:keywords => %w(Dog Cat Cow)})
    s.should have(3).keywords
    s = Search.new({:keywords => ["Dog","Cat","Cow"]})
    s.should have(3).keywords
  end

  it "should have an array of channels" do
    s = Search.new()
    s.should have(0).channels
    s = Search.new({:channels => "running,swimming,yoga"})
    s.should have(3).channels
    s = Search.new({:channels => %w(running swimming yoga)})
    s.should have(3).channels
    s = Search.new({:channels => ["running","swimming","yoga"]})
    s.should have(3).channels
  end
  
  it "should have defaults set" do
    s = Search.new()
    uri = URI.parse( s.end_point )
    uri.query.include?("f=#{Facet.ACTIVITIES}").should be_true    
    uri.query.include?("s=#{Sort.DATE_ASC}").should be_true    
    uri.query.include?("r=50").should be_true    
    uri.query.include?("v=json").should be_true    
    uri.query.include?("page=1").should be_true    
    uri.query.should have_param("num=10")
    uri.query.should have_param("daterange:today..+")
    uri.query.should_not have_param("assetId=")
  end
  
  it "should construct a valid url with location" do
    s = Search.new( {:location => "San Diego, CA, US"} )
    uri = URI.parse(s.end_point)
    uri.scheme.should eql("http")
    uri.host.should eql("search.active.com")
    uri.query.should have_param("l=#{CGI.escape("San Diego, CA, US")}")
  end
  
  it "should send an array of zips" do
    uri = URI.parse( Search.new( {:zips => "92121, 92078, 92114"} ).end_point )
    uri.query.should have_param("l=92121,92078,92114")    
    uri = URI.parse( Search.new( {:zips => [92121, 92078, 92114]} ).end_point )
    uri.query.should have_param("l=92121,92078,92114")    
  end
  
  # it "should construct a valid url from a zip code" do
  #   s   = Search.new( {:zip => "92121"} )
  #   uri = URI.parse(s.end_point)    
  #   uri.query.should have_param("l=#{CGI.escape("92121")}")
  # end
  
  it "should construct a valid url with CSV keywords" do
    s   = Search.new( {:keywords => "running, tri"} )
    uri = URI.parse( s.end_point )
    uri.query.should have_param("k=running+tri")
    s   = Search.new( {:keywords => ["running","tri","cycling"]} )
    uri = URI.parse( s.end_point )
    uri.query.should have_param("k=running+tri+cycling")    
  end

  it "should construct a valid url with channels array" do
    s = Search.new( {:channels => [:running, :tri,:cycling, :yoga]} )
    uri = URI.parse( s.end_point )
    uri.query.should have_param("m=meta:channel=Running+OR+meta:channel=Cycling+OR+meta:channel=Mind%2520%2526%2520Body%255CYoga")        
  end
  
  it "should send valid channel info" do
    uri = URI.parse( Search.new({:channels => [:running,:triathlon]}).end_point )
    uri.query.include?("meta:channel=Running+OR+meta:channel=Triathlon").should be_true
  end
  
  it "should send the correct channel value for everything in Search.CHANNELS" do
    Categories.CHANNELS.each do |key,value|
      uri   = URI.parse( Search.new({:channels => [key]}).end_point )
      value = URI.escape(value, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))
      value = URI.escape(value, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))
      value.gsub!(/\-/,"%252D")
      uri.query.should have_param("meta:channel=#{value}")        
    end
  end
  
  it "should send a valid start and end date" do
    uri = URI.parse( Search.new().end_point )
    uri.query.should have_param("daterange:today..+")
  end

  it "should send a valid start and end date" do
    uri = URI.parse( Search.new({:start_date => Date.new(2010, 11, 1), :end_date => Date.new(2010, 11, 15)}).end_point )    
    uri.query.include?("meta:startDate:daterange:11%2F01%2F2010..11%2F15%2F2010").should be_true                
  end
  
  it "should be valid with date range and channels" do
    uri = URI.parse( Search.new({:channels => [:running, :triathlon],
                                           :start_date => Date.new(2010, 11, 1),
                                           :end_date => Date.new(2010, 11, 15)}).end_point )
    uri.query.should have_param("meta:channel=Running+OR+meta:channel=Triathlon")
    uri.query.should have_param("daterange:11%2F01%2F2010..11%2F15%2F2010")
  end
  
  it "should pass the search radius" do
    uri = URI.parse( Search.new({:radius => '666'}).end_point )
    uri.query.should have_param("r=666")
  end
  
  it "should pass the given asset_id" do
    s = Search.new({:asset_id => "12-34" })
    s.should have(1).asset_ids    
  end
  
  it "should pass the given asset_id's" do
    s = Search.new({:asset_ids => ["12-34","5-67","77-7"] })
    s.should have(3).asset_ids
    uri = URI.parse( s.end_point )    
    uri.query.should_not have_param("m=+AND+")
    uri.query.should have_param("meta:assetId%3D12%252d34+OR+meta:assetId%3D5%252d67+OR+meta:assetId%3D77%252d7")
  end
  
  it "should pass a query" do
    # uri = URI.parse( Search.search({:num_results => 50, :radius => "50", :query => "soccer"}).end_point )
    # uri.query.should have_param("q=soccer")    
    pending
  end
  
  it "should probably encode the query value" do
    pending
    # uri = URI.parse( Search.search({:num_results => 50, :radius => "50", :query => "soccer balls"}).end_point )
    # uri.query.should have_param("q=soccer+balls")  What kind of encoding do we need        
  end
  
  it "should decode this JSON" do
    # if the location is not in the correct format there is a json error.
    # s = Active::Services::Search.search({:location => "belvedere-tiburon-ca"})
    # /search?api_key=&num=10&page=1&l=belvedere-tiburon-ca&f=activities&v=json&r=50&s=date_asc&k=&m=meta:startDate:daterange:today..+
    # I think the JSON spec says that only arrays or objects can be at the top level.
    # JSON::ParserError: A JSON text must at least contain two octets!
    pending
  end
  
end

describe "Handle http server codes" do 
  after(:each) do 
    FakeWeb.clean_registry
  end
  
  it "should follow a 302" do
    FakeWeb.register_uri(:get, "http://search.active.com/search?api_key=&num=10&page=1&l=San+Diego%2C+CA%2C+US&f=activities&v=json&r=50&s=date_asc&k=&m=meta:startDate:daterange:today..+", 
                         :body => '{"endIndex":3,"numberOfResults":3,"pageSize":3,"searchTime":0.600205,"_results":[{"escapedUrl": "http://www.active.com/running/calabasas-ca/calabasas-classic-5k-10k-runs-2010","language": "en","title": "Calabasas Classic 2010 - 5k \u003cb\u003e10k\u003c/b\u003e Runs | Calabasas, California 91302 \u003cb\u003e...\u003c/b\u003e","url": "http://www.active.com/running/calabasas-ca/calabasas-classic-5k-10k-runs-2010","summary": "\u003cb\u003e...\u003c/b\u003e Calabasas Classic 2010 - 5k \u003cb\u003e10k\u003c/b\u003e Runs. Based on 0 reviews. \u003cb\u003e...\u003c/b\u003e Recent Reviews Calabasas\u003cbr\u003e Classic 2010 - 5k \u003cb\u003e10k\u003c/b\u003e Runs reviews. Get Directions. Start Address. End Address \u003cb\u003e...\u003c/b\u003e  ","meta": {"startDate": "2010-11-14","eventDate": "2010-11-14T08:00:00-08:00","location": "Calabasas Park Centre","tag": ["event:10", "Green:10", "Running:10"],"state": "California","eventLongitude": "-118.6789","endDate": "2010-11-14","locationName": "Calabasas Park Centre","splitMediaType": ["Event", "1 mile", "10K", "5K"],"endTime": "8:00:00","mediaType": ["Event", "Event\\1 mile", "Event\\10K", "Event\\5K"],"google-site-verification": "","city": "Calabasas","startTime": "8:00:00","assetId": ["11B01475-8C65-4F9C-A4AC-2A3FA55FE8CD", "11b01475-8c65-4f9c-a4ac-2a3fa55fe8cd"],"eventId": "1810531","participationCriteria": "All","description": "","longitude": "-118.6789","onlineDonationAvailable": "false","substitutionUrl": "1810531","assetName": ["Calabasas Classic 2010 -  5k 10k Runs", "Calabasas Classic 2010 -  5k 10k Runs"],"zip": "91302","contactPhone": "818-715-0428","sortDate": "2000-11-14","eventState": "California","eventLatitude": "34.12794","keywords": "Event","eventAddress": "23975 Park Sorrento","contactEmail": "rot10kd@yahoo.com","onlineMembershipAvailable": "false","trackbackurl": "http://www.active.com/running/calabasas-ca/calabasas-classic-5k-10k-runs-2010","country": "United States","onlineRegistrationAvailable": "true","category": "Activities","image1": "http://www.active.com/images/events/hotrace.gif","assetTypeId": "EA4E860A-9DCD-4DAA-A7CA-4A77AD194F65","lastModifiedDate": "2010-03-04 07:30:26.307","eventZip": "91302","latitude": "34.12794","UpdateDateTime": "8/18/2010 10:16:26 AM","channel": ["Running", "Walking"]}},
                         {"escapedUrl": "http://www.active.com/10k-race/seattle-wa/fitness-for-vitality-5k10k-3race-series-919-2010","language": "en","title": "Fitness For Vitality 5k/\u003cb\u003e10k\u003c/b\u003e 3-Race Series (9/19, 10/17, 11/21) \u003cb\u003e...\u003c/b\u003e","url": "http://www.active.com/10k-race/seattle-wa/fitness-for-vitality-5k10k-3race-series-919-2010","summary": "\u003cb\u003e...\u003c/b\u003e Fitness For Vitality 5k/\u003cb\u003e10k\u003c/b\u003e 3-Race Series (9/19, 10/17, 11/21). Based on 0 reviews. \u003cb\u003e...\u003c/b\u003e\u003cbr\u003e Reviews of Fitness For Vitality 5k/\u003cb\u003e10k\u003c/b\u003e 3-Race Series (9/19, 10. \u003cb\u003e...\u003c/b\u003e  ","meta": {"summary": "\u003cp style\u003dtext-align:left\u003e\u003cfont style\u003dfont-family:UniversEmbedded;font-size:12;color:#000000; LETTERSPACING\u003d0 KERNING\u003d0\u003eRace or walk on a flat, fast, and fun course! The entire event is along the Puget Sound. Do all 3 events in the series and watch your time and fitness improve! Oatmeal post-race. 10% proceeds sh","startDate": "2010-09-19","eventDate": "2010-09-19","location": "Alki Beach Park, Seattle","tag": ["event:10", "Running:10"],"state": "Washington","endDate": "2010-11-22","locationName": "1702 Alki Ave. SW","splitMediaType": ["5K", "difficulty:Beginner", "difficulty:Advanced", "Event", "difficulty:Intermediate", "10K"],"lastModifiedDateTime": "2010-08-19 23:35:50.117","endTime": "07:59:59","mediaType": ["5K", "difficulty:Beginner", "difficulty:Advanced", "Event", "difficulty:Intermediate", "10K"],"google-site-verification": "","city": "Seattle","startTime": "07:00:00","assetId": ["39e8177e-dd0e-42a2-8a2b-24055e5325f3", "39e8177e-dd0e-42a2-8a2b-24055e5325f3"],"eventId": "E-000NGFS9","participationCriteria": "Kids,Family","description": "","longitude": "-122.3912","substitutionUrl": "E-000NGFS9","assetName": ["Fitness For Vitality 5k/10k 3-Race Series (9/19, 10/17, 11/21)", "Fitness For Vitality 5k/10k 3-Race Series (9/19, 10/17, 11/21)"],"zip": "98136","contactPhone": "n/a","eventState": "WA","sortDate": "2000-09-19","keywords": "Event","eventAddress": "1702 Alki Ave. SW","contactEmail": "n/a","dma": "Seattle - Tacoma","trackbackurl": "http://www.active.com/10k-race/seattle-wa/fitness-for-vitality-5k10k-3race-series-919-2010","seourl": "http://www.active.com/10k-race/seattle-wa/fitness-for-vitality-5k10k-3race-series-919-2010","country": "United States","onlineRegistrationAvailable": "true","category": "Activities","image1": "http://photos-images.active.com/file/3/1/optimized/9015e50d-3a2e-4ce4-9ddc-80b05b973b01.jpg","allText": "\u003cp style\u003dtext-align:left\u003e\u003cfont style\u003dfont-family:UniversEmbedded;font-size:12;color:#000000; LETTERSPACING\u003d0 KERNING\u003d0\u003eRace or walk on a flat, fast, and fun course! The entire event is along the Puget Sound. Do all 3 events in the series and watch your time and fitness improve! Oatmeal post-race. 10% proceeds sh","address": "1702 Alki Ave. SW","assetTypeId": "DFAA997A-D591-44CA-9FB7-BF4A4C8984F1","lastModifiedDate": "2010-08-19","eventZip": "98136","latitude": "47.53782","UpdateDateTime": "8/18/2010 10:16:08 AM","channel": "Running"}},
                         {"escapedUrl": "http://www.active.com/running/calabasas-ca/calabasas-classic-5k-10k-runs-2010","language": "en","title": "Calabasas Classic 2010 - 5k \u003cb\u003e10k\u003c/b\u003e Runs | Calabasas, California 91302 \u003cb\u003e...\u003c/b\u003e","url": "http://www.active.com/running/calabasas-ca/calabasas-classic-5k-10k-runs-2010","summary": "\u003cb\u003e...\u003c/b\u003e Calabasas Classic 2010 - 5k \u003cb\u003e10k\u003c/b\u003e Runs. Based on 0 reviews. \u003cb\u003e...\u003c/b\u003e Recent Reviews Calabasas\u003cbr\u003e Classic 2010 - 5k \u003cb\u003e10k\u003c/b\u003e Runs reviews. Get Directions. Start Address. End Address \u003cb\u003e...\u003c/b\u003e  ","meta": {"startDate": "2010-11-14","eventDate": "2010-11-14T08:00:00-08:00","location": "Calabasas Park Centre","tag": ["event:10", "Green:10", "Running:10"],"state": "California","eventLongitude": "-118.6789","endDate": "2010-11-14","locationName": "Calabasas Park Centre","splitMediaType": ["Event", "1 mile", "10K", "5K"],"endTime": "8:00:00","mediaType": ["Event", "Event\\1 mile", "Event\\10K", "Event\\5K"],"google-site-verification": "","city": "Calabasas","startTime": "8:00:00","assetId": ["11B01475-8C65-4F9C-A4AC-2A3FA55FE8CD", "11b01475-8c65-4f9c-a4ac-2a3fa55fe8cd"],"eventId": "1810531","participationCriteria": "All","description": "","longitude": "-118.6789","onlineDonationAvailable": "false","substitutionUrl": "1810531","assetName": ["Calabasas Classic 2010 -  5k 10k Runs", "Calabasas Classic 2010 -  5k 10k Runs"],"zip": "91302","contactPhone": "818-715-0428","sortDate": "2000-11-14","eventState": "California","eventLatitude": "34.12794","keywords": "Event","eventAddress": "23975 Park Sorrento","contactEmail": "rot10kd@yahoo.com","onlineMembershipAvailable": "false","trackbackurl": "http://www.active.com/running/calabasas-ca/calabasas-classic-5k-10k-runs-2010","country": "United States","onlineRegistrationAvailable": "true","category": "Activities","image1": "http://www.active.com/images/events/hotrace.gif","assetTypeId": "EA4E860A-9DCD-4DAA-A7CA-4A77AD194F65","lastModifiedDate": "2010-03-04 07:30:26.307","eventZip": "91302","latitude": "34.12794","UpdateDateTime": "8/18/2010 10:16:26 AM","channel": ["Running", "Walking"]}}]}',
                         :status => ["302", "Found"])
    s = Search.search( {:location => "San Diego, CA, US"} )
    s.should have(3).results    
  end
  
end

describe Search do
  after(:each) do 
    FakeWeb.clean_registry
  end
    
  it "should have some channels" do
    Categories.CHANNELS.should_not be_nil
  end
  
  it "should describe pagination info on search object" do
    FakeWeb.register_uri(:get, "http://search.active.com/search?api_key=&num=10&page=1&l=San+Diego%2C+CA%2C+US&f=activities&v=json&r=50&s=date_asc&k=&m=meta:startDate:daterange:today..+", 
                         :body => '{"endIndex":3,"numberOfResults":3,"pageSize":5,"searchTime":0.600205,"_results":[{"escapedUrl": "http://www.active.com/running/calabasas-ca/calabasas-classic-5k-10k-runs-2010","language": "en","title": "Calabasas Classic 2010 - 5k \u003cb\u003e10k\u003c/b\u003e Runs | Calabasas, California 91302 \u003cb\u003e...\u003c/b\u003e","url": "http://www.active.com/running/calabasas-ca/calabasas-classic-5k-10k-runs-2010","summary": "\u003cb\u003e...\u003c/b\u003e Calabasas Classic 2010 - 5k \u003cb\u003e10k\u003c/b\u003e Runs. Based on 0 reviews. \u003cb\u003e...\u003c/b\u003e Recent Reviews Calabasas\u003cbr\u003e Classic 2010 - 5k \u003cb\u003e10k\u003c/b\u003e Runs reviews. Get Directions. Start Address. End Address \u003cb\u003e...\u003c/b\u003e  ","meta": {"startDate": "2010-11-14","eventDate": "2010-11-14T08:00:00-08:00","location": "Calabasas Park Centre","tag": ["event:10", "Green:10", "Running:10"],"state": "California","eventLongitude": "-118.6789","endDate": "2010-11-14","locationName": "Calabasas Park Centre","splitMediaType": ["Event", "1 mile", "10K", "5K"],"endTime": "8:00:00","mediaType": ["Event", "Event\\1 mile", "Event\\10K", "Event\\5K"],"google-site-verification": "","city": "Calabasas","startTime": "8:00:00","assetId": ["11B01475-8C65-4F9C-A4AC-2A3FA55FE8CD", "11b01475-8c65-4f9c-a4ac-2a3fa55fe8cd"],"eventId": "1810531","participationCriteria": "All","description": "","longitude": "-118.6789","onlineDonationAvailable": "false","substitutionUrl": "1810531","assetName": ["Calabasas Classic 2010 -  5k 10k Runs", "Calabasas Classic 2010 -  5k 10k Runs"],"zip": "91302","contactPhone": "818-715-0428","sortDate": "2000-11-14","eventState": "California","eventLatitude": "34.12794","keywords": "Event","eventAddress": "23975 Park Sorrento","contactEmail": "rot10kd@yahoo.com","onlineMembershipAvailable": "false","trackbackurl": "http://www.active.com/running/calabasas-ca/calabasas-classic-5k-10k-runs-2010","country": "United States","onlineRegistrationAvailable": "true","category": "Activities","image1": "http://www.active.com/images/events/hotrace.gif","assetTypeId": "EA4E860A-9DCD-4DAA-A7CA-4A77AD194F65","lastModifiedDate": "2010-03-04 07:30:26.307","eventZip": "91302","latitude": "34.12794","UpdateDateTime": "8/18/2010 10:16:26 AM","channel": ["Running", "Walking"]}},
                         {"escapedUrl": "http://www.active.com/10k-race/seattle-wa/fitness-for-vitality-5k10k-3race-series-919-2010","language": "en","title": "Fitness For Vitality 5k/\u003cb\u003e10k\u003c/b\u003e 3-Race Series (9/19, 10/17, 11/21) \u003cb\u003e...\u003c/b\u003e","url": "http://www.active.com/10k-race/seattle-wa/fitness-for-vitality-5k10k-3race-series-919-2010","summary": "\u003cb\u003e...\u003c/b\u003e Fitness For Vitality 5k/\u003cb\u003e10k\u003c/b\u003e 3-Race Series (9/19, 10/17, 11/21). Based on 0 reviews. \u003cb\u003e...\u003c/b\u003e\u003cbr\u003e Reviews of Fitness For Vitality 5k/\u003cb\u003e10k\u003c/b\u003e 3-Race Series (9/19, 10. \u003cb\u003e...\u003c/b\u003e  ","meta": {"summary": "\u003cp style\u003dtext-align:left\u003e\u003cfont style\u003dfont-family:UniversEmbedded;font-size:12;color:#000000; LETTERSPACING\u003d0 KERNING\u003d0\u003eRace or walk on a flat, fast, and fun course! The entire event is along the Puget Sound. Do all 3 events in the series and watch your time and fitness improve! Oatmeal post-race. 10% proceeds sh","startDate": "2010-09-19","eventDate": "2010-09-19","location": "Alki Beach Park, Seattle","tag": ["event:10", "Running:10"],"state": "Washington","endDate": "2010-11-22","locationName": "1702 Alki Ave. SW","splitMediaType": ["5K", "difficulty:Beginner", "difficulty:Advanced", "Event", "difficulty:Intermediate", "10K"],"lastModifiedDateTime": "2010-08-19 23:35:50.117","endTime": "07:59:59","mediaType": ["5K", "difficulty:Beginner", "difficulty:Advanced", "Event", "difficulty:Intermediate", "10K"],"google-site-verification": "","city": "Seattle","startTime": "07:00:00","assetId": ["39e8177e-dd0e-42a2-8a2b-24055e5325f3", "39e8177e-dd0e-42a2-8a2b-24055e5325f3"],"eventId": "E-000NGFS9","participationCriteria": "Kids,Family","description": "","longitude": "-122.3912","substitutionUrl": "E-000NGFS9","assetName": ["Fitness For Vitality 5k/10k 3-Race Series (9/19, 10/17, 11/21)", "Fitness For Vitality 5k/10k 3-Race Series (9/19, 10/17, 11/21)"],"zip": "98136","contactPhone": "n/a","eventState": "WA","sortDate": "2000-09-19","keywords": "Event","eventAddress": "1702 Alki Ave. SW","contactEmail": "n/a","dma": "Seattle - Tacoma","trackbackurl": "http://www.active.com/10k-race/seattle-wa/fitness-for-vitality-5k10k-3race-series-919-2010","seourl": "http://www.active.com/10k-race/seattle-wa/fitness-for-vitality-5k10k-3race-series-919-2010","country": "United States","onlineRegistrationAvailable": "true","category": "Activities","image1": "http://photos-images.active.com/file/3/1/optimized/9015e50d-3a2e-4ce4-9ddc-80b05b973b01.jpg","allText": "\u003cp style\u003dtext-align:left\u003e\u003cfont style\u003dfont-family:UniversEmbedded;font-size:12;color:#000000; LETTERSPACING\u003d0 KERNING\u003d0\u003eRace or walk on a flat, fast, and fun course! The entire event is along the Puget Sound. Do all 3 events in the series and watch your time and fitness improve! Oatmeal post-race. 10% proceeds sh","address": "1702 Alki Ave. SW","assetTypeId": "DFAA997A-D591-44CA-9FB7-BF4A4C8984F1","lastModifiedDate": "2010-08-19","eventZip": "98136","latitude": "47.53782","UpdateDateTime": "8/18/2010 10:16:08 AM","channel": "Running"}},
                         {"escapedUrl": "http://www.active.com/running/calabasas-ca/calabasas-classic-5k-10k-runs-2010","language": "en","title": "Calabasas Classic 2010 - 5k \u003cb\u003e10k\u003c/b\u003e Runs | Calabasas, California 91302 \u003cb\u003e...\u003c/b\u003e","url": "http://www.active.com/running/calabasas-ca/calabasas-classic-5k-10k-runs-2010","summary": "\u003cb\u003e...\u003c/b\u003e Calabasas Classic 2010 - 5k \u003cb\u003e10k\u003c/b\u003e Runs. Based on 0 reviews. \u003cb\u003e...\u003c/b\u003e Recent Reviews Calabasas\u003cbr\u003e Classic 2010 - 5k \u003cb\u003e10k\u003c/b\u003e Runs reviews. Get Directions. Start Address. End Address \u003cb\u003e...\u003c/b\u003e  ","meta": {"startDate": "2010-11-14","eventDate": "2010-11-14T08:00:00-08:00","location": "Calabasas Park Centre","tag": ["event:10", "Green:10", "Running:10"],"state": "California","eventLongitude": "-118.6789","endDate": "2010-11-14","locationName": "Calabasas Park Centre","splitMediaType": ["Event", "1 mile", "10K", "5K"],"endTime": "8:00:00","mediaType": ["Event", "Event\\1 mile", "Event\\10K", "Event\\5K"],"google-site-verification": "","city": "Calabasas","startTime": "8:00:00","assetId": ["11B01475-8C65-4F9C-A4AC-2A3FA55FE8CD", "11b01475-8c65-4f9c-a4ac-2a3fa55fe8cd"],"eventId": "1810531","participationCriteria": "All","description": "","longitude": "-118.6789","onlineDonationAvailable": "false","substitutionUrl": "1810531","assetName": ["Calabasas Classic 2010 -  5k 10k Runs", "Calabasas Classic 2010 -  5k 10k Runs"],"zip": "91302","contactPhone": "818-715-0428","sortDate": "2000-11-14","eventState": "California","eventLatitude": "34.12794","keywords": "Event","eventAddress": "23975 Park Sorrento","contactEmail": "rot10kd@yahoo.com","onlineMembershipAvailable": "false","trackbackurl": "http://www.active.com/running/calabasas-ca/calabasas-classic-5k-10k-runs-2010","country": "United States","onlineRegistrationAvailable": "true","category": "Activities","image1": "http://www.active.com/images/events/hotrace.gif","assetTypeId": "EA4E860A-9DCD-4DAA-A7CA-4A77AD194F65","lastModifiedDate": "2010-03-04 07:30:26.307","eventZip": "91302","latitude": "34.12794","UpdateDateTime": "8/18/2010 10:16:26 AM","channel": ["Running", "Walking"]}}]}',
                         :status => ["200", "Found"])
    s = Search.search( {:location => "San Diego, CA, US"} )
    s.should be_a_kind_of(Search)
    s.should have(3).results
    s.endIndex.should == 3
    s.numberOfResults.should == 3
    s.pageSize.should == 5
    s.searchTime.should == 0.600205
    
  end
  
  it "should raise and error during a 404" do
    FakeWeb.register_uri(:get, "http://search.active.com/search?api_key=&num=10&page=1&l=San+Diego%2C+CA%2C+US&f=activities&v=json&r=50&s=date_asc&k=&m=meta:startDate:daterange:today..+", 
                         :body => "Nothing to be found 'round here", :status => ["404", "Not Found"])
    lambda { Search.search( {:location => "San Diego, CA, US"} ) }.should raise_error(RuntimeError)                         
  end
  
  it "should search by location (san diego)" do
    FakeWeb.register_uri(:get, "http://search.active.com/search?api_key=&num=10&page=1&l=San+Diego%2C+CA%2C+US&f=activities&v=json&r=50&s=date_asc&k=&m=meta:startDate:daterange:today..+", 
                         :body => '{"endIndex":3,"numberOfResults":3,"pageSize":5,"searchTime":0.600205,"_results":[{"escapedUrl": "http://www.active.com/running/calabasas-ca/calabasas-classic-5k-10k-runs-2010","language": "en","title": "Calabasas Classic 2010 - 5k \u003cb\u003e10k\u003c/b\u003e Runs | Calabasas, California 91302 \u003cb\u003e...\u003c/b\u003e","url": "http://www.active.com/running/calabasas-ca/calabasas-classic-5k-10k-runs-2010","summary": "\u003cb\u003e...\u003c/b\u003e Calabasas Classic 2010 - 5k \u003cb\u003e10k\u003c/b\u003e Runs. Based on 0 reviews. \u003cb\u003e...\u003c/b\u003e Recent Reviews Calabasas\u003cbr\u003e Classic 2010 - 5k \u003cb\u003e10k\u003c/b\u003e Runs reviews. Get Directions. Start Address. End Address \u003cb\u003e...\u003c/b\u003e  ","meta": {"startDate": "2010-11-14","eventDate": "2010-11-14T08:00:00-08:00","location": "Calabasas Park Centre","tag": ["event:10", "Green:10", "Running:10"],"state": "California","eventLongitude": "-118.6789","endDate": "2010-11-14","locationName": "Calabasas Park Centre","splitMediaType": ["Event", "1 mile", "10K", "5K"],"endTime": "8:00:00","mediaType": ["Event", "Event\\1 mile", "Event\\10K", "Event\\5K"],"google-site-verification": "","city": "Calabasas","startTime": "8:00:00","assetId": ["11B01475-8C65-4F9C-A4AC-2A3FA55FE8CD", "11b01475-8c65-4f9c-a4ac-2a3fa55fe8cd"],"eventId": "1810531","participationCriteria": "All","description": "","longitude": "-118.6789","onlineDonationAvailable": "false","substitutionUrl": "1810531","assetName": ["Calabasas Classic 2010 -  5k 10k Runs", "Calabasas Classic 2010 -  5k 10k Runs"],"zip": "91302","contactPhone": "818-715-0428","sortDate": "2000-11-14","eventState": "California","eventLatitude": "34.12794","keywords": "Event","eventAddress": "23975 Park Sorrento","contactEmail": "rot10kd@yahoo.com","onlineMembershipAvailable": "false","trackbackurl": "http://www.active.com/running/calabasas-ca/calabasas-classic-5k-10k-runs-2010","country": "United States","onlineRegistrationAvailable": "true","category": "Activities","image1": "http://www.active.com/images/events/hotrace.gif","assetTypeId": "EA4E860A-9DCD-4DAA-A7CA-4A77AD194F65","lastModifiedDate": "2010-03-04 07:30:26.307","eventZip": "91302","latitude": "34.12794","UpdateDateTime": "8/18/2010 10:16:26 AM","channel": ["Running", "Walking"]}},
                         {"escapedUrl": "http://www.active.com/10k-race/seattle-wa/fitness-for-vitality-5k10k-3race-series-919-2010","language": "en","title": "Fitness For Vitality 5k/\u003cb\u003e10k\u003c/b\u003e 3-Race Series (9/19, 10/17, 11/21) \u003cb\u003e...\u003c/b\u003e","url": "http://www.active.com/10k-race/seattle-wa/fitness-for-vitality-5k10k-3race-series-919-2010","summary": "\u003cb\u003e...\u003c/b\u003e Fitness For Vitality 5k/\u003cb\u003e10k\u003c/b\u003e 3-Race Series (9/19, 10/17, 11/21). Based on 0 reviews. \u003cb\u003e...\u003c/b\u003e\u003cbr\u003e Reviews of Fitness For Vitality 5k/\u003cb\u003e10k\u003c/b\u003e 3-Race Series (9/19, 10. \u003cb\u003e...\u003c/b\u003e  ","meta": {"summary": "\u003cp style\u003dtext-align:left\u003e\u003cfont style\u003dfont-family:UniversEmbedded;font-size:12;color:#000000; LETTERSPACING\u003d0 KERNING\u003d0\u003eRace or walk on a flat, fast, and fun course! The entire event is along the Puget Sound. Do all 3 events in the series and watch your time and fitness improve! Oatmeal post-race. 10% proceeds sh","startDate": "2010-09-19","eventDate": "2010-09-19","location": "Alki Beach Park, Seattle","tag": ["event:10", "Running:10"],"state": "Washington","endDate": "2010-11-22","locationName": "1702 Alki Ave. SW","splitMediaType": ["5K", "difficulty:Beginner", "difficulty:Advanced", "Event", "difficulty:Intermediate", "10K"],"lastModifiedDateTime": "2010-08-19 23:35:50.117","endTime": "07:59:59","mediaType": ["5K", "difficulty:Beginner", "difficulty:Advanced", "Event", "difficulty:Intermediate", "10K"],"google-site-verification": "","city": "Seattle","startTime": "07:00:00","assetId": ["39e8177e-dd0e-42a2-8a2b-24055e5325f3", "39e8177e-dd0e-42a2-8a2b-24055e5325f3"],"eventId": "E-000NGFS9","participationCriteria": "Kids,Family","description": "","longitude": "-122.3912","substitutionUrl": "E-000NGFS9","assetName": ["Fitness For Vitality 5k/10k 3-Race Series (9/19, 10/17, 11/21)", "Fitness For Vitality 5k/10k 3-Race Series (9/19, 10/17, 11/21)"],"zip": "98136","contactPhone": "n/a","eventState": "WA","sortDate": "2000-09-19","keywords": "Event","eventAddress": "1702 Alki Ave. SW","contactEmail": "n/a","dma": "Seattle - Tacoma","trackbackurl": "http://www.active.com/10k-race/seattle-wa/fitness-for-vitality-5k10k-3race-series-919-2010","seourl": "http://www.active.com/10k-race/seattle-wa/fitness-for-vitality-5k10k-3race-series-919-2010","country": "United States","onlineRegistrationAvailable": "true","category": "Activities","image1": "http://photos-images.active.com/file/3/1/optimized/9015e50d-3a2e-4ce4-9ddc-80b05b973b01.jpg","allText": "\u003cp style\u003dtext-align:left\u003e\u003cfont style\u003dfont-family:UniversEmbedded;font-size:12;color:#000000; LETTERSPACING\u003d0 KERNING\u003d0\u003eRace or walk on a flat, fast, and fun course! The entire event is along the Puget Sound. Do all 3 events in the series and watch your time and fitness improve! Oatmeal post-race. 10% proceeds sh","address": "1702 Alki Ave. SW","assetTypeId": "DFAA997A-D591-44CA-9FB7-BF4A4C8984F1","lastModifiedDate": "2010-08-19","eventZip": "98136","latitude": "47.53782","UpdateDateTime": "8/18/2010 10:16:08 AM","channel": "Running"}},
                         {"escapedUrl": "http://www.active.com/running/calabasas-ca/calabasas-classic-5k-10k-runs-2010","language": "en","title": "Calabasas Classic 2010 - 5k \u003cb\u003e10k\u003c/b\u003e Runs | Calabasas, California 91302 \u003cb\u003e...\u003c/b\u003e","url": "http://www.active.com/running/calabasas-ca/calabasas-classic-5k-10k-runs-2010","summary": "\u003cb\u003e...\u003c/b\u003e Calabasas Classic 2010 - 5k \u003cb\u003e10k\u003c/b\u003e Runs. Based on 0 reviews. \u003cb\u003e...\u003c/b\u003e Recent Reviews Calabasas\u003cbr\u003e Classic 2010 - 5k \u003cb\u003e10k\u003c/b\u003e Runs reviews. Get Directions. Start Address. End Address \u003cb\u003e...\u003c/b\u003e  ","meta": {"startDate": "2010-11-14","eventDate": "2010-11-14T08:00:00-08:00","location": "Calabasas Park Centre","tag": ["event:10", "Green:10", "Running:10"],"state": "California","eventLongitude": "-118.6789","endDate": "2010-11-14","locationName": "Calabasas Park Centre","splitMediaType": ["Event", "1 mile", "10K", "5K"],"endTime": "8:00:00","mediaType": ["Event", "Event\\1 mile", "Event\\10K", "Event\\5K"],"google-site-verification": "","city": "Calabasas","startTime": "8:00:00","assetId": ["11B01475-8C65-4F9C-A4AC-2A3FA55FE8CD", "11b01475-8c65-4f9c-a4ac-2a3fa55fe8cd"],"eventId": "1810531","participationCriteria": "All","description": "","longitude": "-118.6789","onlineDonationAvailable": "false","substitutionUrl": "1810531","assetName": ["Calabasas Classic 2010 -  5k 10k Runs", "Calabasas Classic 2010 -  5k 10k Runs"],"zip": "91302","contactPhone": "818-715-0428","sortDate": "2000-11-14","eventState": "California","eventLatitude": "34.12794","keywords": "Event","eventAddress": "23975 Park Sorrento","contactEmail": "rot10kd@yahoo.com","onlineMembershipAvailable": "false","trackbackurl": "http://www.active.com/running/calabasas-ca/calabasas-classic-5k-10k-runs-2010","country": "United States","onlineRegistrationAvailable": "true","category": "Activities","image1": "http://www.active.com/images/events/hotrace.gif","assetTypeId": "EA4E860A-9DCD-4DAA-A7CA-4A77AD194F65","lastModifiedDate": "2010-03-04 07:30:26.307","eventZip": "91302","latitude": "34.12794","UpdateDateTime": "8/18/2010 10:16:26 AM","channel": ["Running", "Walking"]}}]}',
                         :status => ["200", "Found"])
    s = Search.search( {:location => "San Diego, CA, US"} )
    s.should be_a_kind_of(Search)
    s.should have(3).results
    s.results.each do |a|
      a.should be_an_instance_of(Activity)
      a.title.should_not be_nil
      a.start_date.should_not be_nil
      a.end_date.should_not be_nil
      a.categories.should_not be_nil
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
  
  it "should handle a JSON parse error" do
    # /search?api_key=&num=10&page=1&l=0&f=activities&v=json&r=50&s=trending&k=&m=meta:startDate:daterange:today..+
    # FakeWeb.register_uri(:get, "http://search.active.com/search?api_key=&num=10&page=1&l=San+Diego%2C+CA%2C+US&f=activities&v=json&r=50&s=date_asc&k=&m=meta:startDate:daterange:today..+", 
    #                      :body => '{"endIndex":10,"numberOfResults":2810,"pageSize":10,"searchTime":0.86581,"_results":[{"escapedUrl":"http://www.active.com/running/myrtle-beach-sc/myrtle-beach-mini-marathon-2010","language":"en","title":"Myrtle Beach Mini Marathon | Myrtle Beach, South Carolina \u003cb\u003e...\u003c/b\u003e","url":"http://www.active.com/running/myrtle-beach-sc/myrtle-beach-mini-marathon-2010","summary":"","meta":{"eventDate":"2010-10-24T07:00:00-07:00","location":"Myrtle Beach, South Carolina","tag":["event:10","Running:10"],"endDate":"2010-10-24","eventLongitude":"-78.92921","splitMediaType":["Event","5K","Half Marathon","Marathon","\u003ddifficulty:Advanced","\u003ddifficulty:Beginner","\u003ddifficulty:Intermediate"],"lastModifiedDateTime":"2010-09-13 18:15:04.753","locationName":"Myrtle Beach, South Carolina","endTime":"7:00:00","google-site-verification":"","city":"Myrtle Beach","startTime":"7:00:00","eventId":"1797753","description":"","longitude":"-78.92921","substitutionUrl":"1797753","eventLatitude":"33.75043","eventState":"South Carolina","sortDate":"2000-10-24","keywords":"Event","eventAddress":"Medieval Times","dma":"Florence - Myrtle Beach","seourl":"http://www.active.com/running/myrtle-beach-sc/myrtle-beach-mini-marathon-2010","country":"United States","category":"Activities","market":"Florence - Myrtle Beach","assetTypeId":"EA4E860A-9DCD-4DAA-A7CA-4A77AD194F65","contactName":"Robert Pozo","eventZip":"29579","latitude":"33.75043","UpdateDateTime":"9/1/2010 6:09:21 PM","startDate":"2010-10-24","state":"South Carolina","mediaType":["Event","Event\\5K","Event\\Half Marathon","Event\\Marathon","\u003ddifficulty:Advanced","\u003ddifficulty:Beginner","\u003ddifficulty:Intermediate"],"estParticipants":"6000","assetId":["008540A9-C2AB-4D7F-BE68-298758B324CD","008540a9-c2ab-4d7f-be68-298758b324cd"],"participationCriteria":"Adult,Men,Women","onlineDonationAvailable":"1","assetName":["Myrtle Beach Mini Marathon","Myrtle Beach Mini Marathon"],"eventURL":"http://runmyrtlebeach.com","zip":"29579","contactPhone":"1-800-733-7089","contactEmail":"info@runmyrtlebeach.com","onlineMembershipAvailable":"0","trackbackurl":"http://www.active.com/running/myrtle-beach-sc/myrtle-beach-mini-marathon-2010","onlineRegistrationAvailable":"1","image1":"http://www.active.com/images/events/hotrace.gif","lastModifiedDate":"2010-09-13","channel":"Running"}},{"escapedUrl":"http://www.active.com/running/denver-co/fans-on-the-field-denver-stadium-5k10k-2010","language":"en","title":"Fans on the Field 2010 - Denver Stadium 5K/10K | Denver \u003cb\u003e...\u003c/b\u003e","url":"http://www.active.com/running/denver-co/fans-on-the-field-denver-stadium-5k10k-2010","summary":"","meta":{"startDate":"2010-10-10","eventDate":"2010-10-10T00:00:00-07:00","location":"INVESCO Field at Mile High","tag":["event:10","Running:10"],"state":"Colorado","eventLongitude":"-105.0265","endDate":"2010-10-10","lastModifiedDateTime":"2010-08-05 16:15:18.14","splitMediaType":["Event","10K","5K"],"locationName":"INVESCO Field at Mile High","endTime":"0:00:00","mediaType":["Event","Event\\10K","Event\\5K"],"city":"Denver","google-site-verification":"","startTime":"0:00:00","assetId":["4850BB73-3701-493D-936C-C38CC0B3FD4C","4850bb73-3701-493d-936c-c38cc0b3fd4c"],"eventId":"1869635","participationCriteria":"All","description":"","longitude":"-105.0265","onlineDonationAvailable":"false","substitutionUrl":"1869635","assetName":["Fans on the Field 2010 - Denver Stadium 5K/10K","Fans on the Field 2010 - Denver Stadium 5K/10K"],"zip":"80204","contactPhone":"303-293-5315","eventLatitude":"39.73804","eventState":"Colorado","sortDate":"2000-10-10","keywords":"Event","eventAddress":"1801 Bryant Street","contactEmail":"ahinkle@nscd.org","onlineMembershipAvailable":"false","trackbackurl":"http://www.active.com/running/denver-co/fans-on-the-field-denver-stadium-5k10k-2010","country":"United States","onlineRegistrationAvailable":"true","category":"Activities","image1":"http://www.active.com/images/events/hotrace.gif","assetTypeId":"EA4E860A-9DCD-4DAA-A7CA-4A77AD194F65","lastModifiedDate":"2010-08-05","eventZip":"80204","UpdateDateTime":"9/1/2010 6:09:21 PM","latitude":"39.73804","channel":["Running","Walking"]}},{"escapedUrl":"http://www.active.com/running/west-palm-beach-fl/the-palm-beaches-marathon-festival-2010","language":"en","title":"The Palm Beaches Marathon Festival | West Palm Beach \u003cb\u003e...\u003c/b\u003e","url":"http://www.active.com/running/west-palm-beach-fl/the-palm-beaches-marathon-festival-2010","summary":"","meta":{"eventDate":"2010-12-05T06:00:00-08:00","location":"West Palm Beach, Florida","tag":["event:10","Running:10"],"endDate":"2010-12-05","eventLongitude":"-80.06707","splitMediaType":["Event","5K","Half Marathon","Marathon","Relay"],"lastModifiedDateTime":"2010-09-10 13:15:05.057","locationName":"West Palm Beach, Florida","endTime":"6:00:00","google-site-verification":"","city":"West Palm Beach","startTime":"6:00:00","eventId":"1815427","description":"","longitude":"-80.06707","substitutionUrl":"1815427","eventLatitude":"26.72339","eventState":"Florida","sortDate":"2000-12-05","keywords":"Event","eventAddress":"S. Flagler Drive and Evernia St.","dma":"West Palm Beach - Fort Pierce","seourl":"http://www.active.com/running/west-palm-beach-fl/the-palm-beaches-marathon-festival-2010","country":"United States","category":"Activities","market":"West Palm Beach - Fort Pierce","assetTypeId":"EA4E860A-9DCD-4DAA-A7CA-4A77AD194F65","contactName":"Iva Grady","eventZip":"33401","latitude":"26.72339","UpdateDateTime":"9/1/2010 6:09:21 PM","startDate":"2010-12-05","state":"Florida","mediaType":["Event","Event\\5K","Event\\Half Marathon","Event\\Marathon","Event\\Relay"],"estParticipants":"8000","assetId":["EA86AD3C-FBBA-403A-9DDB-1D211C210225","ea86ad3c-fbba-403a-9ddb-1d211c210225"],"participationCriteria":"All","onlineDonationAvailable":"0","assetName":["The Palm Beaches Marathon Festival","The Palm Beaches Marathon Festival"],"eventURL":"http://www.pbmarathon.com","zip":"33401","contactPhone":"561-833-3711  ex. 222","contactEmail":"info@marathonofthepalmbeaches.com","onlineMembershipAvailable":"0","trackbackurl":"http://www.active.com/running/west-palm-beach-fl/the-palm-beaches-marathon-festival-2010","onlineRegistrationAvailable":"1","image1":"http://www.active.com/images/events/hotrace.gif","lastModifiedDate":"2010-09-10","channel":"Running"}},{"escapedUrl":"http://www.active.com/running/encino-ca/2nd-annual-wespark-10k-run-and-5k-run-walk-2010","language":"en","title":"2nd Annual weSPARK 10K Run \u0026amp; 5K Run Walk | Encino \u003cb\u003e...\u003c/b\u003e","url":"http://www.active.com/running/encino-ca/2nd-annual-wespark-10k-run-and-5k-run-walk-2010","summary":"","meta":{"eventDate":"2010-11-14T08:00:00-08:00","location":"Balboa Park/Lake Balboa","tag":["event:10","Running:10"],"endDate":"2010-11-14","eventLongitude":"-118.4924","splitMediaType":["Event","10K","5K"],"lastModifiedDateTime":"2010-08-23 13:16:00.843","locationName":"Balboa Park/Lake Balboa","endTime":"8:00:00","google-site-verification":"","city":"Encino","startTime":"8:00:00","eventId":"1847738","description":"","longitude":"-118.4924","substitutionUrl":"1847738","eventLatitude":"34.19933","eventState":"California","sortDate":"2000-11-14","keywords":"Event","eventAddress":"6335 Woodley Avenue","dma":"Los Angeles","seourl":"http://www.active.com/running/encino-ca/2nd-annual-wespark-10k-run-and-5k-run-walk-2010","country":"United States","category":"Activities","market":"Los Angeles","contactName":"Lilliane Ballesteros","assetTypeId":"EA4E860A-9DCD-4DAA-A7CA-4A77AD194F65","eventZip":"91406","latitude":"34.19933","UpdateDateTime":"9/1/2010 6:09:21 PM","startDate":"2010-11-14","state":"California","mediaType":["Event","Event\\10K","Event\\5K"],"estParticipants":"1400","assetId":["D9A22F33-8A14-4175-8D5B-D11578212A98","d9a22f33-8a14-4175-8d5b-d11578212a98"],"participationCriteria":"All","onlineDonationAvailable":"0","assetName":["2nd Annual weSPARK 10K Run \u0026 5K Run Walk","2nd Annual weSPARK 10K Run \u0026 5K Run Walk"],"eventURL":"http://www.wespark.org","zip":"91406","contactPhone":"818-906-3022","contactEmail":"lilliane@wespark.org","onlineMembershipAvailable":"0","trackbackurl":"http://www.active.com/running/encino-ca/2nd-annual-wespark-10k-run-and-5k-run-walk-2010","onlineRegistrationAvailable":"1","image1":"http://www.active.com/images/events/hotrace.gif","lastModifiedDate":"2010-08-23","channel":["Running","Walking"]}},{"escapedUrl":"http://www.active.com/running/los-angeles-playa-del-rey-ca/heroes-of-hope-race-for-research-2010","language":"en","title":"Heroes of Hope Race for Research | Los Angeles, Playa Del \u003cb\u003e...\u003c/b\u003e","url":"http://www.active.com/running/los-angeles-playa-del-rey-ca/heroes-of-hope-race-for-research-2010","summary":"","meta":{"eventDate":"2010-11-07T08:00:00-08:00","location":"Dockweiler State Beach","tag":["event:10","Running:10"],"endDate":"2010-11-07","eventLongitude":"-118.4392","splitMediaType":["Event","10K","5K"],"lastModifiedDateTime":"2010-09-09 07:15:48.193","locationName":"Dockweiler State Beach","endTime":"8:00:00","google-site-verification":"","city":"Los Angeles, Playa Del Rey","startTime":"8:00:00","eventId":"1858905","description":"","longitude":"-118.4392","substitutionUrl":"1858905","eventLatitude":"33.9495","eventState":"California","sortDate":"2000-11-07","keywords":"Event","eventAddress":"8255 Vista Del Mar Blvd","dma":"Los Angeles","seourl":"http://www.active.com/running/los-angeles-playa-del-rey-ca/heroes-of-hope-race-for-research-2010","country":"United States","category":"Activities","market":"Los Angeles","assetTypeId":"EA4E860A-9DCD-4DAA-A7CA-4A77AD194F65","contactName":"Lisa Kaminsky-Millar","eventZip":"90293","latitude":"33.9495","UpdateDateTime":"9/1/2010 6:09:21 PM","startDate":"2010-11-07","state":"California","mediaType":["Event","Event\\10K","Event\\5K"],"estParticipants":"1000","assetId":["0D92AB40-ED0B-4657-B00B-480B38062F1C","0d92ab40-ed0b-4657-b00b-480b38062f1c"],"participationCriteria":"All","onlineDonationAvailable":"1","assetName":["Heroes of Hope Race for Research","Heroes of Hope Race for Research"],"eventURL":"http://www.heroesofhoperace.org","zip":"90293","contactPhone":"1-866-48-4CURE","contactEmail":"heroesofhoperace@gmail.com","onlineMembershipAvailable":"0","trackbackurl":"http://www.active.com/running/los-angeles-playa-del-rey-ca/heroes-of-hope-race-for-research-2010","onlineRegistrationAvailable":"1","image1":"http://www.active.com/images/events/hotrace.gif","lastModifiedDate":"2010-09-09","channel":"Running"}},{"escapedUrl":"http://www.active.com/running/calabasas-ca/calabasas-classic-5k-10k-runs-2010","language":"en","title":"Calabasas Classic 2010 - 5k 10k Runs | Calabasas, California \u003cb\u003e...\u003c/b\u003e","url":"http://www.active.com/running/calabasas-ca/calabasas-classic-5k-10k-runs-2010","summary":"","meta":{"eventDate":"2010-11-14T08:00:00-08:00","location":"Calabasas Park Centre","tag":["event:10","Green:10","Running:10"],"endDate":"2010-11-14","eventLongitude":"-118.6789","splitMediaType":["Event","1 mile","10K","5K"],"lastModifiedDateTime":"2010-09-14 21:02:55.007","locationName":"Calabasas Park Centre","endTime":"8:00:00","google-site-verification":"","city":"Calabasas","startTime":"8:00:00","eventId":"1810531","description":"","longitude":"-118.6789","substitutionUrl":"1810531","eventLatitude":"34.12794","eventState":"California","sortDate":"2000-11-14","keywords":"Event","eventAddress":"23975 Park Sorrento","dma":"Los Angeles","seourl":"http://www.active.com/running/calabasas-ca/calabasas-classic-5k-10k-runs-2010","country":"United States","category":"Activities","market":"Los Angeles","contactName":"Julie Talbert","assetTypeId":"EA4E860A-9DCD-4DAA-A7CA-4A77AD194F65","eventZip":"91302","latitude":"34.12794","UpdateDateTime":"9/1/2010 6:09:21 PM","startDate":"2010-11-14","state":"California","mediaType":["Event","Event\\1 mile","Event\\10K","Event\\5K"],"estParticipants":"2500","assetId":["11B01475-8C65-4F9C-A4AC-2A3FA55FE8CD","11b01475-8c65-4f9c-a4ac-2a3fa55fe8cd"],"participationCriteria":"All","onlineDonationAvailable":"0","assetName":["Calabasas Classic 2010 -  5k 10k Runs","Calabasas Classic 2010 -  5k 10k Runs"],"eventURL":"http://www.calabasasclassic.com","zip":"91302","contactPhone":"818-715-0428","contactEmail":"rot10kd@yahoo.com","onlineMembershipAvailable":"0","trackbackurl":"http://www.active.com/running/calabasas-ca/calabasas-classic-5k-10k-runs-2010","onlineRegistrationAvailable":"1","image1":"http://www.active.com/images/events/hotrace.gif","lastModifiedDate":"2010-09-14","channel":["Running","Walking"]}},{"escapedUrl":"http://www.active.com/triathlon/miami-fl/ironman-703-miami-2010","language":"en","title":"IRONMAN 70.3 MIAMI | Miami, Florida 33132 | Saturday \u003cb\u003e...\u003c/b\u003e","url":"http://www.active.com/triathlon/miami-fl/ironman-703-miami-2010","summary":"","meta":{"startDate":"2010-10-30","eventDate":"2010-10-30T07:00:00-07:00","location":"Bayfront Park - Downtown Miami","tag":["event:10","Triathlon:10"],"state":"Florida","eventLongitude":"-80.18975","endDate":"2010-10-30","lastModifiedDateTime":"2010-05-10 11:16:04.46","splitMediaType":["Event","Ironman","Long Course","\u003ddifficulty:Advanced","\u003ddifficulty:Intermediate"],"locationName":"Bayfront Park - Downtown Miami","endTime":"7:00:00","mediaType":["Event","Event\\Ironman","Event\\Long Course","\u003ddifficulty:Advanced","\u003ddifficulty:Intermediate"],"city":"Miami","google-site-verification":"","startTime":"7:00:00","assetId":["72FAE9F7-5C68-4DF8-B01C-B63AC188A06A","72fae9f7-5c68-4df8-b01c-b63ac188a06a"],"eventId":"1800302","participationCriteria":"Adult,Family,Men,Women","description":"","longitude":"-80.18975","onlineDonationAvailable":"false","substitutionUrl":"1800302","assetName":["IRONMAN 70.3 MIAMI","IRONMAN 70.3 MIAMI"],"zip":"33132","contactPhone":"3053072285","eventLatitude":"25.78649","eventState":"Florida","sortDate":"2000-10-30","keywords":"Event","eventAddress":"301 N. Biscayne Blvd.","contactEmail":"jennifer@miamitrievents.com","onlineMembershipAvailable":"false","trackbackurl":"http://www.active.com/triathlon/miami-fl/ironman-703-miami-2010","country":"United States","onlineRegistrationAvailable":"true","category":"Activities","image1":"http://www.active.com/images/events/hotrace.gif","assetTypeId":"EA4E860A-9DCD-4DAA-A7CA-4A77AD194F65","lastModifiedDate":"2010-05-10","eventZip":"33132","UpdateDateTime":"9/1/2010 6:09:21 PM","latitude":"25.78649","channel":"Triathlon"}},{"escapedUrl":"http://www.active.com/triathlon/san-juan-na/ironman-703-san-juan-2011-ig329","language":"en","title":"2011 Ironman 70.3 San Juan | San Juan, 00901 | Saturday \u003cb\u003e...\u003c/b\u003e","url":"http://www.active.com/triathlon/san-juan-na/ironman-703-san-juan-2011-ig329","summary":"","meta":{"startDate":"2011-03-19","eventDate":"2011-03-19T07:00:00-07:00","location":"Los Rosales Street, San Geronimo Grounds","tag":["event:10","Triathlon:10"],"state":"N/A","endDate":"2011-03-19","eventLongitude":"-66.10572","lastModifiedDateTime":"2010-06-15 14:15:08.557","splitMediaType":["Event","Ironman","\u003ddifficulty:Advanced"],"locationName":"Los Rosales Street, San Geronimo Grounds","endTime":"7:00:00","mediaType":["Event","Event\\Ironman","\u003ddifficulty:Advanced"],"city":"San Juan","google-site-verification":"","startTime":"7:00:00","assetId":["F6B819B9-9CC1-4E67-A87D-11518B05D4F3","f6b819b9-9cc1-4e67-a87d-11518b05d4f3"],"eventId":"1841595","participationCriteria":"Adult","description":"","longitude":"-66.10572","onlineDonationAvailable":"false","substitutionUrl":"1841595","assetName":["2011 Ironman 70.3 San Juan","2011 Ironman 70.3 San Juan"],"zip":"00901","contactPhone":"813-868-5940","eventLatitude":"18.46633","sortDate":"2001-03-19","keywords":"Event","contactEmail":"info@bnsportsllc.com","onlineMembershipAvailable":"false","trackbackurl":"http://www.active.com/triathlon/san-juan-na/ironman-703-san-juan-2011-ig329","country":"Puerto Rico","onlineRegistrationAvailable":"true","category":"Activities","image1":"http://www.active.com/images/events/hotrace.gif","assetTypeId":"EA4E860A-9DCD-4DAA-A7CA-4A77AD194F65","lastModifiedDate":"2010-06-15","eventZip":"00901","latitude":"18.46633","UpdateDateTime":"9/1/2010 6:09:21 PM","channel":"Triathlon"}},{"escapedUrl":"http://www.active.com/triathlon/st-george-ut/ford-ironman-st-george-2011","language":"en","title":"2011 Ford Ironman St. George | St. George, Utah 84737 \u003cb\u003e...\u003c/b\u003e","url":"http://www.active.com/triathlon/st-george-ut/ford-ironman-st-george-2011","summary":"","meta":{"startDate":"2011-05-07","eventDate":"2011-05-07T07:00:00-07:00","location":"Sand Hollow State Park,","tag":["event:10","Triathlon:10"],"state":"Utah","eventLongitude":"-113.1508","endDate":"2011-05-07","lastModifiedDateTime":"2010-07-22 11:15:08.46","splitMediaType":["Event","Ironman","Long Course"],"locationName":"Sand Hollow State Park,","endTime":"7:00:00","mediaType":["Event","Event\\Ironman","Event\\Long Course"],"city":"St. George","google-site-verification":"","startTime":"7:00:00","assetId":["A10B5BC1-BD95-4AFE-A1F6-35F6099E3636","a10b5bc1-bd95-4afe-a1f6-35f6099e3636"],"eventId":"1848350","participationCriteria":"All","description":"","longitude":"-113.1508","onlineDonationAvailable":"false","substitutionUrl":"1848350","assetName":["2011 Ford Ironman St. George","2011 Ford Ironman St. George"],"zip":"84737","contactPhone":"813-868-5940","eventLatitude":"37.15574","eventState":"Utah","sortDate":"2001-05-07","keywords":"Event","eventAddress":"4405 West 3600 South","contactEmail":"stgeorge@ironman.com","onlineMembershipAvailable":"false","trackbackurl":"http://www.active.com/triathlon/st-george-ut/ford-ironman-st-george-2011","country":"United States","onlineRegistrationAvailable":"true","category":"Activities","image1":"http://www.active.com/images/events/hotrace.gif","assetTypeId":"3BF82BBE-CF88-4E8C-A56F-78F5CE87E4C6","lastModifiedDate":"2010-07-22","eventZip":"84737","UpdateDateTime":"9/1/2010 6:09:21 PM","latitude":"37.15574","channel":"Triathlon"}},{"escapedUrl":"http://www.active.com/triathlon/galveston-tx/memorial-hermann-ironman-703-texas-and-lonestar-sprint-triathlon-2011","language":"en","title":"2011 Memorial Hermann Ironman 70.3 Texas \u0026amp; Lonestar \u003cb\u003e...\u003c/b\u003e","url":"http://www.active.com/triathlon/galveston-tx/memorial-hermann-ironman-703-texas-and-lonestar-sprint-triathlon-2011","summary":"","meta":{"startDate":"2011-04-09","eventDate":"2011-04-09T07:00:00-07:00","location":"Moody Gardens","state":"Texas","endDate":"2011-04-10","eventLongitude":"-94.90395","lastModifiedDateTime":"2010-05-12 09:16:41.91","splitMediaType":["Event","Ironman","Long Course","Sprint"],"locationName":"Moody Gardens","endTime":"7:00:00","mediaType":["Event","Event\\Ironman","Event\\Long Course","Event\\Sprint"],"city":"Galveston","google-site-verification":"","startTime":"7:00:00","assetId":["A40CC533-D502-4953-8157-DBB64D7FC4C2","a40cc533-d502-4953-8157-dbb64d7fc4c2"],"eventId":"1859810","participationCriteria":"All","description":"","longitude":"-94.90395","onlineDonationAvailable":"false","substitutionUrl":"1859810","assetName":["2011 Memorial Hermann Ironman 70.3 Texas \u0026 Lonestar Sprint Triathlon","2011 Memorial Hermann Ironman 70.3 Texas \u0026 Lonestar Sprint Triathlon"],"zip":"77554","contactPhone":"813-868-5940","eventLatitude":"29.24699","eventState":"Texas","sortDate":"2001-04-09","keywords":"Event","contactEmail":"texas70.3@ironman.com","onlineMembershipAvailable":"false","trackbackurl":"http://www.active.com/triathlon/galveston-tx/memorial-hermann-ironman-703-texas-and-lonestar-sprint-triathlon-2011","country":"United States","onlineRegistrationAvailable":"true","category":"Activities","image1":"http://www.active.com/images/events/hotrace.gif","assetTypeId":"3BF82BBE-CF88-4E8C-A56F-78F5CE87E4C6","lastModifiedDate":"2010-05-12","eventZip":"77554","latitude":"29.24699","UpdateDateTime":"9/1/2010 6:09:21 PM","channel":"Triathlon"}}]}',
    #                      :status => ["200", "Found"])
    # This query is throwing this error "source did not contain any JSON!" and we need to handle it
    # s = Search.search( {:radius=>"50", :keywords=>"", :page=>1, :num_results=>10, :location=>"0"} )
    pending
  end

end

describe "Call Live Data" do
  
  it "should find only events in the future" do
    s = Search.search( { :keywords => ["running"] } )
    s.should have(10).results
    s.results.each do |a|
      a.start_date.should satisfy { |d|
        d >= Date.today
      }
    end
  end

  it "should find only events with in a range" do
    s = Search.search( {:start_date => Date.new(2010,1,1), :end_date => Date.new(2010,2,1)} )
    s.should have(10).results
    s.results.each do |a|
      a.start_date.should satisfy { |d|
        d >= Date.new(2010,1,1) and d <= Date.new(2010,2,1)
      }
    end
  end

  it "should find events after the start date" do
    s = Search.search( {:start_date => Date.new(2010,1,1), :num_results => 50} )
    s.should have(50).results
    s.results.each do |a|
      a.start_date.should satisfy { |d|
        d >= Date.new(2010,1,1) 
      }
    end
    s.results.each do |a|
      a.asset_id.should_not be_nil
    end
  end
  
  # our model should be updated to handle multiple categories 
  # I'm sure running is with in all of these events but we're only storing 1.
  # it "should find only running activities" do
  #   s = Search.search( {:channels => [:running],
  #                             :start_date => Date.new(2010,1,1), :num_results => 20} )
  #   s.should have(20).results    
  #   s.results.each do |a|
  #     puts "-#{a.category}-"
  #     a.category.should satisfy { |d|
  #       d.include?('Running' )
  #     }
  #   end
  # end
  
  it "should find yoga activities by channel" do
    s = Search.search( {:channels => [:yoga]} )
    s.should have(10).results        
  end
  
  it "should not set sort to an empty string" do
    # s = Search.search( {:sort => ""} )
    # s.sort.should_not be_empty
    pending
  end
  
  it "should get results given these area codes" do
    s = Search.search( {:zips => "92121, 92078, 92114"} )
    s.should be_an_instance_of Search
    s.results.should_not be_empty
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
  
  it "should order by the date created" do
  #   results = Search.search( {:channels => ['Running'], :sort => 'created_at_asc'} )
    pending
  end
  
end


describe  "Parametric search" do
  describe  "Parametric search for running channel" do
    it "should find by splitMediaType for the Running channel" do
      # http://developer.active.com/docs/Activecom_Search_API_Reference
    end  
  end
  describe  "Parametric search for triathlon channel" do
  end  
end

describe "Find things within X miles to me" do
  it "should find activities within 20 miles of me" do
    # l=lat;lng&r=50
    pending
  end
end

