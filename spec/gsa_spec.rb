# Require the spec helper relative to this file
require File.join(File.dirname(__FILE__), %w[spec_helper])
require File.join(File.dirname(__FILE__), %w[custom_matchers_spec])
require File.join(File.dirname(__FILE__), %w[ .. lib services search])
require File.join(File.dirname(__FILE__), %w[ .. lib services activity])
require File.join(File.dirname(__FILE__), %w[ .. lib services reg_center])
require File.join(File.dirname(__FILE__), %w[ .. lib services address])
include Active::Services
# EFF92D9D-D487-4FBD-A879-38B3D3BBC8CD
describe GSA do
  before(:each) do 
    @a = GSA.new(JSON.parse('{"escapedUrl":"http://www.active.com/triathlon/oceanside-ca/rohto-ironman-703-california-2011","language":"en","title":"2011 Rohto Ironman 70.3 California | Oceanside, California \u003cb\u003e...\u003c/b\u003e","url":"http://www.active.com/triathlon/oceanside-ca/rohto-ironman-703-california-2011","summary":"","meta":{"eventDate":"2011-04-02T00:00:00-07:00","location":"Oceanside Harbor","tag":["event:10","Triathlon:10"],"eventLongitude":"-117.3586","endDate":"2011-04-02","locationName":"Oceanside Harbor","lastModifiedDateTime":"2010-09-30 06:16:05.107","splitMediaType":["Event","Ironman","Long Course"],"endTime":"0:00:00","city":"Oceanside","google-site-verification":"","startTime":"0:00:00","eventId":"1838902","description":"","longitude":"-117.3586","substitutionUrl":"1838902","sortDate":"2001-04-02","eventState":"California","eventLatitude":"33.19783","keywords":"Event","eventAddress":"1540 Harbor Drive North","dma":"San Diego","seourl":"http://www.active.com/triathlon/oceanside-ca/rohto-ironman-703-california-2011","country":"United States","category":"Activities","market":"San Diego","contactName":"World Triathlon Corporation","assetTypeId":"3BF82BBE-CF88-4E8C-A56F-78F5CE87E4C6","eventZip":"92054","UpdateDateTime":"9/22/2010 11:46:24 AM","latitude":"33.19783","startDate":"2011-04-02","state":"California","mediaType":["Event","Event\\Ironman","Event\\Long Course"],"estParticipants":"2500","assetId":["77ACABBD-BA83-4C78-925D-CE49DEDDF20C","77acabbd-ba83-4c78-925d-ce49deddf20c"],"participationCriteria":"All","onlineDonationAvailable":"0","assetName":["2011 Rohto Ironman 70.3 California","2011 Rohto Ironman 70.3 California"],"zip":"92054","eventURL":"http://www.ironmancalifornia.com/","contactPhone":"813-868-5940","contactEmail":"california70.3@ironman.com","onlineMembershipAvailable":"0","trackbackurl":"http://www.active.com/triathlon/oceanside-ca/rohto-ironman-703-california-2011","onlineRegistrationAvailable":"true","image1":"http://www.active.com/images/events/hotrace.gif","lastModifiedDate":"2010-09-30","channel":"Triathlon"}}'))
  end
  it "should have asset ids" do
    @a.asset_id.should_not be_nil
    @a.asset_type_id.should_not be_nil
  end
  # TITLE
  it "should have a clean title" do
   @a.title.should_not be_nil
   @a.title.should eql("2011 Rohto Ironman 70.3 California")
  end
  it "should have a clean title" do
   g = GSA.new(JSON.parse('{"title":"2011 Rohto Ironman 70.3 California\u003cb\u003e...\u003c/b\u003e | Oceanside, California \u003cb\u003e...\u003c/b\u003e"}'))
   g.title.should eql("2011 Rohto Ironman 70.3 California")     
   g = GSA.new(JSON.parse('{"title":"Calabasas Classic 2010 - 5k \u003cb\u003e10k\u003c/b\u003e Runs | Calabasas, California 91302 \u003cb\u003e...\u003c/b\u003e"}'))
   g.title.should eql("Calabasas Classic 2010 - 5k 10k Runs")        
  end 
  it "should have a nil title" do
    GSA.new({}).title.should be_nil
  end
# start date
  it "should have a valid start date" do
    @a.start_date.should_not be_nil
    @a.start_date.should be_an_instance_of(DateTime)
  end
  it "should have nil is no date" do
    g = GSA.new(JSON.parse('{"title":"Calabasas Classic 2010 - 5k \u003cb\u003e10k\u003c/b\u003e Runs | Calabasas, California 91302 \u003cb\u003e...\u003c/b\u003e"}'))
    g.start_date.should be_nil
  end
# end date
  it "should have a valid end date" do
    @a.end_date.should_not be_nil
    @a.end_date.should be_an_instance_of(DateTime)
  end
  it "should have nil is no date" do
    g = GSA.new(JSON.parse('{"title":"Calabasas Classic 2010 - 5k \u003cb\u003e10k\u003c/b\u003e Runs | Calabasas, California 91302 \u003cb\u003e...\u003c/b\u003e"}'))
    g.end_date.should be_nil
  end
# start time
  it "should have a valid start date" do
    @a.start_time.should_not be_nil
    @a.start_time.should be_an_instance_of(DateTime)
  end
  it "should have a valid start date when data has meta.startDate" do
    g = GSA.new(JSON.parse('{"escapedUrl":"http://www.active.com/community-services-class/belmont-ca/modern-teen-adult-2010","language":"en","title":"Modern - Teen Adult | Belmont, CA, 94002 |","url":"http://www.active.com/community-services-class/belmont-ca/modern-teen-adult-2010","summary":"active espn. Active Home | Directory | Community | eteamz | Results | Support |\u003cbr\u003e Event Directors \u0026amp; Organizers. Active.com. New beta search! \u003cb\u003e...\u003c/b\u003e  ","meta":{"summary":"Barefoot dance with emphasis on floor work, release technique, and partnering. Emotion and story line are core elements in this class. Attire is loose fitting clothing any style or color.","startDate":"2010-11-03","tag":"class:10","state":"California","splitMediaType":"Class","lastModifiedDateTime":"2010-09-08 16:32:50.49","mediaType":"Class","city":"Belmont","assetId":"b06cbfb8-ff63-488c-92c6-d060680cc208","description":"","longitude":"-122.2758","substitutionUrl":"belmontparksandrecreation/registrationmain.sdi?source\u003dshowAsset.sdi\u0026activity_id\u003d3722","tags":"1510.306","assetName":"Modern - Teen Adult","zip":"94002","sortDate":"2000-11-03","keywords":"","dma":"San Francisco - Oakland - San Jose","trackbackurl":"http://www.active.com/community-services-class/belmont-ca/modern-teen-adult-2010","seourl":"http://www.active.com/community-services-class/belmont-ca/modern-teen-adult-2010","country":"United States of America","onlineRegistrationAvailable":"true","category":"Activities","assetTypeId":"FB27C928-54DB-4ECD-B42F-482FC3C8681F","lastModifiedDate":"2010-09-08","UpdateDateTime":"8/20/2008 9:03:50 AM","latitude":"37.52021","channel":"Community Services"}}'))
    g.start_time.should_not be_nil    
    g.start_time.should eql(DateTime.parse("Wed, 03 Nov 2010 00:00:00"))
  end
  it "should have nil is no date" do
    g = GSA.new(JSON.parse('{"title":"Calabasas Classic 2010 - 5k \u003cb\u003e10k\u003c/b\u003e Runs | Calabasas, California 91302 \u003cb\u003e...\u003c/b\u003e"}'))
    g.start_time.should be_nil
  end
# end time
  it "should have a valid end date" do
    @a.start_time.should_not be_nil
    @a.start_time.should be_an_instance_of(DateTime)
  end
  it "should have nil is no date" do
    g = GSA.new(JSON.parse('{"title":"Calabasas Classic 2010 - 5k \u003cb\u003e10k\u003c/b\u003e Runs | Calabasas, California 91302 \u003cb\u003e...\u003c/b\u003e"}'))
    g.start_time.should be_nil
  end  
  it "should have an asset_id" do
    GSA.new().asset_id.should be_nil
    @a.asset_id.should_not be_nil
  end
  it "should have an asset_type_id" do
    GSA.new().asset_type_id.should be_nil
    @a.asset_type_id.should_not be_nil
  end
# substitutionUrl
  it "should have an id for substitutionUrl" do
    @a.substitutionUrl.should eql("1838902")
    g = GSA.new(JSON.parse('{"title":"Calabasas", "meta":{"substitutionUrl":"vistarecreation/registrationmain.sdi?source=showAsset.sdi&activity_id=4900"}}'))    
    g.substitutionUrl.should eql("4900")
  end
# bounding_box
  it "should raise an error with a bad bounding box" do
    lambda {s = Search.search({ :bounding_box => { :sw => "37.695141,-123.013657"}}) }.should raise_error(RuntimeError)                         
  end
  it "should search a bounding box String" do
    s = Search.search({ :bounding_box => { :sw => "37.695141,-123.013657", :ne => "37.832371,-122.356979"}})
    r =  s.results.first
    r.address["city"].should eql("San Francisco")
  end
  it "should search a bounding box Hash" do
    s = Search.search({ :bounding_box => { :sw => [37.695141, -123.013657], :ne => [37.832371,-122.356979] }})
    r =  s.results.first
    r.address["city"].should eql("San Francisco")
  end
# address
  it "should have a full address" do
    g = GSA.new(JSON.parse('{"title":"Calabasas", "meta":{"location":"Oceanside Harbor","eventLongitude":"-117.3586","locationName":"Oceanside Harbor","eventAddress":"1540 Harbor Drive North", "city":"San Diego", "eventState":"CA", "eventZip":"92121", "latitude":"-22", "longitude":"222", "country":"USA" }}'))
    g.address.should_not be_nil
    g.address[:name].should eql("Oceanside Harbor")
    g.address[:address].should eql("1540 Harbor Drive North")    
    g.address[:city].should eql("San Diego")
    g.address[:state].should eql("CA")
    g.address[:zip].should eql("92121")
    g.address[:country].should eql("USA")
    g.address[:lat].should eql("-22")
    g.address[:lng].should eql("222")
  end
  it "should have a partial address" do
    g = GSA.new(JSON.parse('{"language":"en", "title":"Zumba Punch Card (Adult) - Oct. (5) | Vista, CA, 92084 |", "url":"http://www.active.com/community-services-class/vista-ca/zumba-punch-card-adult-oct-5-2010", "escapedUrl":"http://www.active.com/community-services-class/vista-ca/zumba-punch-card-adult-oct-5-2010", "meta":{"city":"Vista", "assetId":"3ae995d9-5c16-4176-b44e-fa0577644ca4", "substitutionUrl":"vistarecreation/registrationmain.sdi?source=showAsset.sdi&activity_id=4900", "trackbackurl":"http://www.active.com/community-services-class/vista-ca/zumba-punch-card-adult-oct-5-2010", "onlineRegistrationAvailable":"false", "zip":"92084", "sortDate":"2000-10-02", "category":"Activities", "latitude":"33.2000368", "dma":"San Diego", "lastModifiedDate":"2010-09-29", "tags":"2348.321", "lastModifiedDateTime":"2010-09-29 16:46:43.33", "country":"United States of America", "startDate":"2010-10-02", "assetName":"Zumba Punch Card (Adult) -  Oct. (5)", "summary":"People of all ages are falling in love with Zumba, one of the fastest growing dance-based fitness crazes in the country. With Zumbas easy-to-follow dance moves you receive body beautifying benefits while enjoying Latin rhythms including Salsa, Meringue, Cumbia, Reggaeton, even belly dance and hip-hop. Zumba is ", "description":"", "seourl":"http://www.active.com/community-services-class/vista-ca/zumba-punch-card-adult-oct-5-2010", "channel":"Community Services", "splitMediaType":"Class", "mediaType":"Class", "longitude":"-117.2425355", "UpdateDateTime":"8/20/2008 9:03:50 AM", "assetTypeId":"FB27C928-54DB-4ECD-B42F-482FC3C8681F", "state":"California", "keywords":""}, "summary":""}'))
    g.address[:name].should be_nil
    g.address[:address].should be_nil
    g.address[:city].should eql("Vista")
    g.address[:state].should eql("California")
    g.address[:zip].should eql("92084")
    g.address[:country].should eql("United States of America")
    g.address[:lat].should eql("33.2000368")
    g.address[:lng].should eql("-117.2425355")
  end
  it "should have a address.address" do
    g = GSA.new(JSON.parse('{"escapedUrl":"http://www.active.com/cycling/san-francisco-ca/seismic-challenge-30-2010","language":"en","title":"Seismic Challenge 3.0 | San Francisco, California 94101 \u003cb\u003e...\u003c/b\u003e","url":"http://www.active.com/cycling/san-francisco-ca/seismic-challenge-30-2010","summary":"","meta":{"startDate":"2010-10-02","eventDate":"2010-10-02T00:00:00-07:00","location":"San Francisco Bay","tag":"event:10","state":"California","eventLongitude":"-122.42","endDate":"2010-10-03","lastModifiedDateTime":"2010-10-04 03:08:51.65","splitMediaType":"Event","locationName":"San Francisco Bay","endTime":"0:00:00","mediaType":"Event","city":"San Francisco","google-site-verification":"","estParticipants":"2000","startTime":"0:00:00","assetId":["35A99FCB-E238-4D78-9205-96179F827CB0","35a99fcb-e238-4d78-9205-96179f827cb0"],"eventId":"1883181","participationCriteria":"All","description":"","longitude":"-122.42","onlineDonationAvailable":"0","substitutionUrl":"1883181","assetName":["Seismic Challenge 3.0","Seismic Challenge 3.0"],"eventURL":"http://greaterthanone.org/events/seismic-challenge/","zip":"94101","contactPhone":"415-487-3053","sortDate":"2000-10-02","eventState":"California","eventLatitude":"37.78","keywords":"Event","contactEmail":"eventinfo@sfaf.org","onlineMembershipAvailable":"0","dma":"San Francisco - Oakland - San Jose","trackbackurl":"http://www.active.com/cycling/san-francisco-ca/seismic-challenge-30-2010","seourl":"http://www.active.com/cycling/san-francisco-ca/seismic-challenge-30-2010","country":"United States","onlineRegistrationAvailable":"false","category":"Activities","market":"San Francisco - Oakland - San Jose","assetTypeId":"EA4E860A-9DCD-4DAA-A7CA-4A77AD194F65","lastModifiedDate":"2010-10-04","eventZip":"94101","UpdateDateTime":"9/22/2010 11:46:24 AM","latitude":"37.78","channel":"Cycling"}}'))
    
    g.address[:address].should eql("San Francisco Bay")
    g.address[:name].should eql("San Francisco Bay")
    g.address[:lat].should eql("37.78")
    g.address[:zip].should eql("94101")
    g = GSA.new(JSON.parse('{"escapedUrl":"http://www.active.com/cycling/san-francisco-ca/seismic-challenge-30-2010","language":"en","title":"Seismic Challenge 3.0 | San Francisco, California 94101 \u003cb\u003e...\u003c/b\u003e","url":"http://www.active.com/cycling/san-francisco-ca/seismic-challenge-30-2010","summary":"","meta":{"startDate":"2010-10-02","eventDate":"2010-10-02T00:00:00-07:00","tag":"event:10","state":"California","eventLongitude":"-122.42","endDate":"2010-10-03","lastModifiedDateTime":"2010-10-04 03:08:51.65","splitMediaType":"Event","locationName":"San Francisco Bay","endTime":"0:00:00","mediaType":"Event","city":"San Francisco","google-site-verification":"","estParticipants":"2000","startTime":"0:00:00","assetId":["35A99FCB-E238-4D78-9205-96179F827CB0","35a99fcb-e238-4d78-9205-96179f827cb0"],"eventId":"1883181","participationCriteria":"All","description":"","longitude":"-122.42","onlineDonationAvailable":"0","substitutionUrl":"1883181","assetName":["Seismic Challenge 3.0","Seismic Challenge 3.0"],"eventURL":"http://greaterthanone.org/events/seismic-challenge/","zip":"94101","contactPhone":"415-487-3053","sortDate":"2000-10-02","eventState":"California","eventLatitude":"37.78","keywords":"Event","contactEmail":"eventinfo@sfaf.org","onlineMembershipAvailable":"0","dma":"San Francisco - Oakland - San Jose","trackbackurl":"http://www.active.com/cycling/san-francisco-ca/seismic-challenge-30-2010","seourl":"http://www.active.com/cycling/san-francisco-ca/seismic-challenge-30-2010","country":"United States","onlineRegistrationAvailable":"false","category":"Activities","market":"San Francisco - Oakland - San Jose","assetTypeId":"EA4E860A-9DCD-4DAA-A7CA-4A77AD194F65","lastModifiedDate":"2010-10-04","eventZip":"94101","UpdateDateTime":"9/22/2010 11:46:24 AM","latitude":"37.78","channel":"Cycling"}}'))    
    g.address[:address].should be_nil
  end
  it "should have an address from this hash with null name and address" do
    g = GSA.new(JSON.parse('{"escapedUrl":"http://www.active.com/cycling/san-francisco-ca/california-wine-country-bike-tours-in-october-2010","language":"en","title":"2010 California Wine Country Bike Tours in October | San \u003cb\u003e...\u003c/b\u003e","url":"http://www.active.com/cycling/san-francisco-ca/california-wine-country-bike-tours-in-october-2010","summary":"","meta":{"startDate":"2010-10-10","eventDate":"2010-10-10T00:00:00-07:00","state":"California","endDate":"2010-10-22","eventLongitude":"-122.4200000","lastModifiedDateTime":"2010-08-26 02:15:54.36","splitMediaType":"Event","endTime":"0:00:00","mediaType":"Event","city":"San Francisco","google-site-verification":"","estParticipants":"2000","startTime":"0:00:00","assetId":["81A4A089-CAB5-4293-BFBF-87C74A1C6370","81a4a089-cab5-4293-bfbf-87c74a1c6370"],"eventId":"1889827","participationCriteria":"All","description":"","longitude":"-122.4200000","onlineDonationAvailable":"0","substitutionUrl":"1889827","assetName":["2010 California Wine Country Bike Tours in October","2010 California Wine Country Bike Tours in October"],"eventURL":"http://www.trektravel.com/contentpage.cfm?ID\u003d703","zip":"94101","contactPhone":"866-464-8735","eventLatitude":"37.7800000","eventState":"California","sortDate":"2000-10-10","keywords":"Event","onlineMembershipAvailable":"0","dma":"San Francisco - Oakland - San Jose","trackbackurl":"http://www.active.com/cycling/san-francisco-ca/california-wine-country-bike-tours-in-october-2010","seourl":"http://www.active.com/cycling/san-francisco-ca/california-wine-country-bike-tours-in-october-2010","country":"United States","onlineRegistrationAvailable":"0","category":"Activities","market":"San Francisco - Oakland - San Jose","assetTypeId":"EA4E860A-9DCD-4DAA-A7CA-4A77AD194F65","lastModifiedDate":"2010-08-26","eventZip":"94101","UpdateDateTime":"8/18/2010 10:16:26 AM","latitude":"37.7800000","channel":"Cycling"}}'))
    g.address[:name].should be_nil
    g.address[:address].should be_nil
    g.address[:city].should eql("San Francisco")
    g.address[:state].should eql("California")
    g.address[:zip].should eql("94101")
    g.address[:country].should eql("United States")
    g.address[:lat].should eql("37.7800000")
    g.address[:lng].should eql("-122.4200000")    
  end
  it "should have an address from this hash" do
    g = GSA.new(JSON.parse('{"escapedUrl":"http://www.active.com/running/san-francisco-ca/nike-womens-marathon-2010","language":"en","title":"Nike Women\u0026#39;s Marathon | San Francisco, California 94102 \u003cb\u003e...\u003c/b\u003e","url":"http://www.active.com/running/san-francisco-ca/nike-womens-marathon-2010","summary":"","meta":{"startDate":"2010-10-17","eventDate":"2010-10-17T07:00:00-07:00","location":"Union Square","tag":["event:10","Running:10"],"state":"California","eventLongitude":"-122.4212","endDate":"2010-10-17","lastModifiedDateTime":"2010-10-01 21:04:24.977","splitMediaType":["Event","Marathon"],"locationName":"Union Square","endTime":"7:00:00","mediaType":["Event","Event\\Marathon"],"city":"San Francisco","google-site-verification":"","estParticipants":"2000","startTime":"7:00:00","assetId":["715ED4EF-E4FF-42F2-B24B-2E4255649676","715ed4ef-e4ff-42f2-b24b-2e4255649676"],"eventId":"1854168","participationCriteria":"All","description":"","longitude":"-122.4212","onlineDonationAvailable":"0","substitutionUrl":"1854168","assetName":["Nike Womens Marathon","Nike Womens Marathon"],"eventURL":"http://inside.nike.com/blogs/nikerunning_events-en_US/?tags\u003dnike_womens_marathon_2010","zip":"94102","contactPhone":"866-786-6453","eventState":"California","sortDate":"2000-10-17","eventLatitude":"37.77869","keywords":"Event","onlineMembershipAvailable":"0","dma":"San Francisco - Oakland - San Jose","trackbackurl":"http://www.active.com/running/san-francisco-ca/nike-womens-marathon-2010","seourl":"http://www.active.com/running/san-francisco-ca/nike-womens-marathon-2010","country":"United States","onlineRegistrationAvailable":"false","category":"Activities","market":"San Francisco - Oakland - San Jose","assetTypeId":"EA4E860A-9DCD-4DAA-A7CA-4A77AD194F65","lastModifiedDate":"2010-10-01","eventZip":"94102","UpdateDateTime":"9/22/2010 11:46:24 AM","latitude":"37.77869","channel":"Running"}}'))
    g.address[:name].should eql("Union Square")
    g.address[:address].should eql("Union Square")
    g.address[:city].should eql("San Francisco")
    g.address[:state].should eql("California")
    g.address[:zip].should eql("94102")
    g.address[:country].should eql("United States")
    g.address[:lat].should eql("37.77869")
    g.address[:lng].should eql("-122.4212")    
  end
# USER
  it "should have a nil user email" do
    g = GSA.new(JSON.parse('{"escapedUrl":"http://www.active.com/cycling/san-francisco-ca/seismic-challenge-30-2010","language":"en","title":"Seismic Challenge 3.0 | San Francisco, California 94101 \u003cb\u003e...\u003c/b\u003e","url":"http://www.active.com/cycling/san-francisco-ca/seismic-challenge-30-2010","summary":"","meta":{"startDate":"2010-10-02","eventDate":"2010-10-02T00:00:00-07:00","tag":"event:10","state":"California","eventLongitude":"-122.42","endDate":"2010-10-03","lastModifiedDateTime":"2010-10-04 03:08:51.65","splitMediaType":"Event","locationName":"San Francisco Bay","endTime":"0:00:00","mediaType":"Event","city":"San Francisco","google-site-verification":"","estParticipants":"2000","startTime":"0:00:00","assetId":["35A99FCB-E238-4D78-9205-96179F827CB0","35a99fcb-e238-4d78-9205-96179f827cb0"],"eventId":"1883181","participationCriteria":"All","description":"","longitude":"-122.42","onlineDonationAvailable":"0","substitutionUrl":"1883181","assetName":["Seismic Challenge 3.0","Seismic Challenge 3.0"],"eventURL":"http://greaterthanone.org/events/seismic-challenge/","zip":"94101","contactPhone":"415-487-3053","sortDate":"2000-10-02","eventState":"California","eventLatitude":"37.78","keywords":"Event","onlineMembershipAvailable":"0","dma":"San Francisco - Oakland - San Jose","trackbackurl":"http://www.active.com/cycling/san-francisco-ca/seismic-challenge-30-2010","seourl":"http://www.active.com/cycling/san-francisco-ca/seismic-challenge-30-2010","country":"United States","onlineRegistrationAvailable":"false","category":"Activities","market":"San Francisco - Oakland - San Jose","assetTypeId":"EA4E860A-9DCD-4DAA-A7CA-4A77AD194F65","lastModifiedDate":"2010-10-04","eventZip":"94101","UpdateDateTime":"9/22/2010 11:46:24 AM","latitude":"37.78","channel":"Cycling"}}'))    
    g.user.email.should be_nil    
  end
  it "should have a nil user email" do
    g = GSA.new(JSON.parse('{"escapedUrl":"http://www.active.com/running/san-francisco-ca/nike-womens-marathon-2010","language":"en","title":"Nike Women\u0026#39;s Marathon | San Francisco, California 94102 \u003cb\u003e...\u003c/b\u003e","url":"http://www.active.com/running/san-francisco-ca/nike-womens-marathon-2010","summary":"","meta":{"startDate":"2010-10-17","eventDate":"2010-10-17T07:00:00-07:00","location":"Union Square","tag":["event:10","Running:10"],"state":"California","eventLongitude":"-122.4212","endDate":"2010-10-17","lastModifiedDateTime":"2010-10-01 21:04:24.977","splitMediaType":["Event","Marathon"],"locationName":"Union Square","endTime":"7:00:00","mediaType":["Event","Event\\Marathon"],"city":"San Francisco","google-site-verification":"","estParticipants":"2000","startTime":"7:00:00","assetId":["715ED4EF-E4FF-42F2-B24B-2E4255649676","715ed4ef-e4ff-42f2-b24b-2e4255649676"],"eventId":"1854168","participationCriteria":"All","description":"","longitude":"-122.4212","onlineDonationAvailable":"0","substitutionUrl":"1854168","assetName":["Nike Women\'s Marathon","Nike Women\'s Marathon"],"eventURL":"http://inside.nike.com/blogs/nikerunning_events-en_US/?tags\u003dnike_womens_marathon_2010","zip":"94102","contactPhone":"866-786-6453","eventState":"California","sortDate":"2000-10-17","eventLatitude":"37.77869","keywords":"Event","onlineMembershipAvailable":"0","dma":"San Francisco - Oakland - San Jose","trackbackurl":"http://www.active.com/running/san-francisco-ca/nike-womens-marathon-2010","seourl":"http://www.active.com/running/san-francisco-ca/nike-womens-marathon-2010","country":"United States","onlineRegistrationAvailable":"false","category":"Activities","market":"San Francisco - Oakland - San Jose","assetTypeId":"EA4E860A-9DCD-4DAA-A7CA-4A77AD194F65","lastModifiedDate":"2010-10-01","eventZip":"94102","UpdateDateTime":"9/22/2010 11:46:24 AM","latitude":"37.77869","channel":"Running"}}'))    
    g.user.email.should be_nil    
  end
  it "should have a nil user email when the email is not valid" do
    g = GSA.new(JSON.parse('{"escapedUrl":"http://www.active.com/cycling/san-francisco-ca/seismic-challenge-30-2010","language":"en","title":"Seismic Challenge 3.0 | San Francisco, California 94101 \u003cb\u003e...\u003c/b\u003e","url":"http://www.active.com/cycling/san-francisco-ca/seismic-challenge-30-2010","summary":"","meta":{"startDate":"2010-10-02","eventDate":"2010-10-02T00:00:00-07:00","tag":"event:10","state":"California","eventLongitude":"-122.42","endDate":"2010-10-03","lastModifiedDateTime":"2010-10-04 03:08:51.65","splitMediaType":"Event","locationName":"San Francisco Bay","endTime":"0:00:00","mediaType":"Event","city":"San Francisco","google-site-verification":"","estParticipants":"2000","startTime":"0:00:00","assetId":["35A99FCB-E238-4D78-9205-96179F827CB0","35a99fcb-e238-4d78-9205-96179f827cb0"],"eventId":"1883181","participationCriteria":"All","description":"","longitude":"-122.42","onlineDonationAvailable":"0","substitutionUrl":"1883181","assetName":["Seismic Challenge 3.0","Seismic Challenge 3.0"],"eventURL":"http://greaterthanone.org/events/seismic-challenge/","zip":"94101","contactPhone":"415-487-3053","sortDate":"2000-10-02","eventState":"California","eventLatitude":"37.78","keywords":"Event","contactEmail":"eventfaf.org","onlineMembershipAvailable":"0","dma":"San Francisco - Oakland - San Jose","trackbackurl":"http://www.active.com/cycling/san-francisco-ca/seismic-challenge-30-2010","seourl":"http://www.active.com/cycling/san-francisco-ca/seismic-challenge-30-2010","country":"United States","onlineRegistrationAvailable":"false","category":"Activities","market":"San Francisco - Oakland - San Jose","assetTypeId":"EA4E860A-9DCD-4DAA-A7CA-4A77AD194F65","lastModifiedDate":"2010-10-04","eventZip":"94101","UpdateDateTime":"9/22/2010 11:46:24 AM","latitude":"37.78","channel":"Cycling"}}'))    
    g.user.email.should be_nil
  end
  it "should have a valid user email" do
    g = GSA.new(JSON.parse('{"escapedUrl":"http://www.active.com/cycling/san-francisco-ca/seismic-challenge-30-2010","language":"en","title":"Seismic Challenge 3.0 | San Francisco, California 94101 \u003cb\u003e...\u003c/b\u003e","url":"http://www.active.com/cycling/san-francisco-ca/seismic-challenge-30-2010","summary":"","meta":{"startDate":"2010-10-02","eventDate":"2010-10-02T00:00:00-07:00","tag":"event:10","state":"California","eventLongitude":"-122.42","endDate":"2010-10-03","lastModifiedDateTime":"2010-10-04 03:08:51.65","splitMediaType":"Event","locationName":"San Francisco Bay","endTime":"0:00:00","mediaType":"Event","city":"San Francisco","google-site-verification":"","estParticipants":"2000","startTime":"0:00:00","assetId":["35A99FCB-E238-4D78-9205-96179F827CB0","35a99fcb-e238-4d78-9205-96179f827cb0"],"eventId":"1883181","participationCriteria":"All","description":"","longitude":"-122.42","onlineDonationAvailable":"0","substitutionUrl":"1883181","assetName":["Seismic Challenge 3.0","Seismic Challenge 3.0"],"eventURL":"http://greaterthanone.org/events/seismic-challenge/","zip":"94101","contactPhone":"415-487-3053","sortDate":"2000-10-02","eventState":"California","eventLatitude":"37.78","keywords":"Event","contactEmail":"eventinfo@sfaf.org","onlineMembershipAvailable":"0","dma":"San Francisco - Oakland - San Jose","trackbackurl":"http://www.active.com/cycling/san-francisco-ca/seismic-challenge-30-2010","seourl":"http://www.active.com/cycling/san-francisco-ca/seismic-challenge-30-2010","country":"United States","onlineRegistrationAvailable":"false","category":"Activities","market":"San Francisco - Oakland - San Jose","contactName":"joe","assetTypeId":"EA4E860A-9DCD-4DAA-A7CA-4A77AD194F65","lastModifiedDate":"2010-10-04","eventZip":"94101","UpdateDateTime":"9/22/2010 11:46:24 AM","latitude":"37.78","channel":"Cycling"}}'))    
    g.user.first_name.should eql("joe")
  end
end






