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
  it "should search a bounding box" do
    s = Search.search({ :bounding_box => { :sw => "37.695141,-123.013657", :ne => "37.832371,-122.356979"}})
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
  
end
