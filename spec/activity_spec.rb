# Require the spec helper relative to this file
require File.join(File.dirname(__FILE__), %w[spec_helper])
require File.join(File.dirname(__FILE__), %w[ .. lib services search])
require File.join(File.dirname(__FILE__), %w[ .. lib services activity])
require File.join(File.dirname(__FILE__), %w[ .. lib services IActivity])

# No need to type Britify:: before each call
include Active::Services

describe Activity do
  describe "Creating an activity from a GSA object" do
    before(:each) do 
      @a = Activity.new( GSA.new(JSON.parse('{"escapedUrl":"http://www.active.com/triathlon/oceanside-ca/rohto-ironman-703-california-2011","language":"en","title":"2011 Rohto Ironman 70.3 California | Oceanside, California \u003cb\u003e...\u003c/b\u003e","url":"http://www.active.com/triathlon/oceanside-ca/rohto-ironman-703-california-2011","summary":"","meta":{"eventDate":"2011-04-02T00:00:00-07:00","location":"Oceanside Harbor","tag":["event:10","Triathlon:10"],"eventLongitude":"-117.3586","endDate":"2011-04-02","locationName":"Oceanside Harbor","lastModifiedDateTime":"2010-09-30 06:16:05.107","splitMediaType":["Event","Ironman","Long Course"],"endTime":"0:00:00","city":"Oceanside","google-site-verification":"","startTime":"0:00:00","eventId":"1838902","description":"","longitude":"-117.3586","substitutionUrl":"1838902","sortDate":"2001-04-02","eventState":"California","eventLatitude":"33.19783","keywords":"Event","eventAddress":"1540 Harbor Drive North","dma":"San Diego","seourl":"http://www.active.com/triathlon/oceanside-ca/rohto-ironman-703-california-2011","country":"United States","category":"Activities","market":"San Diego","contactName":"World Triathlon Corporation","assetTypeId":"3BF82BBE-CF88-4E8C-A56F-78F5CE87E4C6","eventZip":"92054","UpdateDateTime":"9/22/2010 11:46:24 AM","latitude":"33.19783","startDate":"2011-04-02","state":"California","mediaType":["Event","Event\\Ironman","Event\\Long Course"],"estParticipants":"2500","assetId":["77ACABBD-BA83-4C78-925D-CE49DEDDF20C","77acabbd-ba83-4c78-925d-ce49deddf20c"],"participationCriteria":"All","onlineDonationAvailable":"0","assetName":["2011 Rohto Ironman 70.3 California","2011 Rohto Ironman 70.3 California"],"zip":"92054","eventURL":"http://www.ironmancalifornia.com/","contactPhone":"813-868-5940","contactEmail":"california70.3@ironman.com","onlineMembershipAvailable":"0","trackbackurl":"http://www.active.com/triathlon/oceanside-ca/rohto-ironman-703-california-2011","onlineRegistrationAvailable":"true","image1":"http://www.active.com/images/events/hotrace.gif","lastModifiedDate":"2010-09-30","channel":"Triathlon"}}')) )
    end
    it "should have asset ids" do
      @a.asset_id.should_not be_nil
      @a.asset_id.should eql("77ACABBD-BA83-4C78-925D-CE49DEDDF20C")
      @a.asset_type_id.should_not be_nil
      @a.asset_type_id.should eql("3BF82BBE-CF88-4E8C-A56F-78F5CE87E4C6")
    end    
    it "should have a title" do
      g = GSA.new(JSON.parse('{"title":"2011 Rohto Ironman 70.3 California\u003cb\u003e...\u003c/b\u003e | Oceanside, California \u003cb\u003e...\u003c/b\u003e"}'))
      g.source.should eql(:gsa)
      g.title.should eql("2011 Rohto Ironman 70.3 California")           
      a = Activity.new( g )
      a.gsa.should_not be_nil
      a.title.should eql("2011 Rohto Ironman 70.3 California")
    end
    # start date
    it "should have a valid start date" do
      @a.start_date.should_not be_nil
      @a.start_date.should be_an_instance_of(DateTime)
    end
    it "should have nil is no date" do
      a = Activity.new( GSA.new(JSON.parse('{"title":"Calabasas Classic 2010 - 5k \u003cb\u003e10k\u003c/b\u003e Runs | Calabasas, California 91302 \u003cb\u003e...\u003c/b\u003e"}')) )
      a.start_date.should be_nil
    end
    # end date
    it "should have a valid end date" do
      @a.end_date.should_not be_nil
      @a.end_date.should be_an_instance_of(DateTime)
    end
    it "should have nil is no date" do
      a = Activity.new( GSA.new(JSON.parse('{"title":"Calabasas Classic 2010 - 5k \u003cb\u003e10k\u003c/b\u003e Runs | Calabasas, California 91302 \u003cb\u003e...\u003c/b\u003e"}')) )
      a.end_date.should be_nil
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
    # asset_id
    it "should have nil is no date" do
      g = Activity.new GSA.new(JSON.parse('{"title":"Calabasas Classic 2010 - 5k \u003cb\u003e10k\u003c/b\u003e Runs | Calabasas, California 91302 \u003cb\u003e...\u003c/b\u003e"}'))
      g.start_time.should be_nil
    end  
    it "should have an asset_id" do
      Activity.new(GSA.new).asset_id.should be_nil
      @a.asset_id.should_not be_nil
    end
    it "should have an asset_type_id" do
      Activity.new(GSA.new).asset_type_id.should be_nil
      @a.asset_type_id.should_not be_nil
    end
    #address
    it "should have a full address" do
      g = Activity.new (GSA.new(JSON.parse('{"title":"Calabasas", "meta":{"location":"Oceanside Harbor","eventLongitude":"-117.3586","locationName":"Oceanside Harbor","eventAddress":"1540 Harbor Drive North", "city":"San Diego", "eventState":"CA", "eventZip":"92121", "latitude":"-22", "longitude":"222", "country":"USA" }}')) )
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
    it "should have a partial address that it's full data doesn't live in WORKS or REGCENTER" do
      g = Activity.new(GSA.new(JSON.parse('{"language":"en", "title":"Zumba Punch Card (Adult) - Oct. (5) | Vista, CA, 92084 |", "url":"http://www.active.com/community-services-class/vista-ca/zumba-punch-card-adult-oct-5-2010", "escapedUrl":"http://www.active.com/community-services-class/vista-ca/zumba-punch-card-adult-oct-5-2010", "meta":{"city":"Vista", "assetId":"3ae995d9-5c16-4176-b44e-fa0577644ca4", "substitutionUrl":"vistarecreation/registrationmain.sdi?source=showAsset.sdi&activity_id=4900", "trackbackurl":"http://www.active.com/community-services-class/vista-ca/zumba-punch-card-adult-oct-5-2010", "onlineRegistrationAvailable":"false", "zip":"92084", "sortDate":"2000-10-02", "category":"Activities", "latitude":"33.2000368", "dma":"San Diego", "lastModifiedDate":"2010-09-29", "tags":"2348.321", "lastModifiedDateTime":"2010-09-29 16:46:43.33", "country":"United States of America", "startDate":"2010-10-02", "assetName":"Zumba Punch Card (Adult) -  Oct. (5)", "summary":"People of all ages are falling in love with Zumba, one of the fastest growing dance-based fitness crazes in the country. With Zumbas easy-to-follow dance moves you receive body beautifying benefits while enjoying Latin rhythms including Salsa, Meringue, Cumbia, Reggaeton, even belly dance and hip-hop. Zumba is ", "description":"", "seourl":"http://www.active.com/community-services-class/vista-ca/zumba-punch-card-adult-oct-5-2010", "channel":"Community Services", "splitMediaType":"Class", "mediaType":"Class", "longitude":"-117.2425355", "UpdateDateTime":"8/20/2008 9:03:50 AM", "assetTypeId":"FB27C928-54DB-4ECD-B42F-482FC3C8681F", "state":"California", "keywords":""}, "summary":""}')))
      g.address[:name].should be_nil # eql("City of Vista Recreation")
      g.address[:address].should be_nil # eql("200 Civic Center Dr.")
      g.address[:city].should eql("Vista")
      g.address[:state].should eql("California")
      g.address[:zip].should eql("92084")
      g.address[:country].should eql("United States of America")
      g.address[:lat].should eql("33.2000368")
      g.address[:lng].should eql("-117.2425355")
    end    
    it "should have an address from this hash with null name and address" do
      g = Activity.new(GSA.new(JSON.parse('{"escapedUrl":"http://www.active.com/cycling/san-francisco-ca/california-wine-country-bike-tours-in-october-2010","language":"en","title":"2010 California Wine Country Bike Tours in October | San \u003cb\u003e...\u003c/b\u003e","url":"http://www.active.com/cycling/san-francisco-ca/california-wine-country-bike-tours-in-october-2010","summary":"","meta":{"startDate":"2010-10-10","eventDate":"2010-10-10T00:00:00-07:00","state":"California","endDate":"2010-10-22","eventLongitude":"-122.4200000","lastModifiedDateTime":"2010-08-26 02:15:54.36","splitMediaType":"Event","endTime":"0:00:00","mediaType":"Event","city":"San Francisco","google-site-verification":"","estParticipants":"2000","startTime":"0:00:00","assetId":["81A4A089-CAB5-4293-BFBF-87C74A1C6370","81a4a089-cab5-4293-bfbf-87c74a1c6370"],"eventId":"1889827","participationCriteria":"All","description":"","longitude":"-122.4200000","onlineDonationAvailable":"0","substitutionUrl":"1889827","assetName":["2010 California Wine Country Bike Tours in October","2010 California Wine Country Bike Tours in October"],"eventURL":"http://www.trektravel.com/contentpage.cfm?ID\u003d703","zip":"94101","contactPhone":"866-464-8735","eventLatitude":"37.7800000","eventState":"California","sortDate":"2000-10-10","keywords":"Event","onlineMembershipAvailable":"0","dma":"San Francisco - Oakland - San Jose","trackbackurl":"http://www.active.com/cycling/san-francisco-ca/california-wine-country-bike-tours-in-october-2010","seourl":"http://www.active.com/cycling/san-francisco-ca/california-wine-country-bike-tours-in-october-2010","country":"United States","onlineRegistrationAvailable":"0","category":"Activities","market":"San Francisco - Oakland - San Jose","assetTypeId":"EA4E860A-9DCD-4DAA-A7CA-4A77AD194F65","lastModifiedDate":"2010-08-26","eventZip":"94101","UpdateDateTime":"8/18/2010 10:16:26 AM","latitude":"37.7800000","channel":"Cycling"}}')))
      g.address[:name].should be_nil
      g.address[:address].should be_nil
      g.address[:city].should eql("San Francisco")
      g.address[:state].should eql("California")
      g.address[:zip].should eql("94101")
      g.address[:country].should eql("United States")
      g.address[:lat].should eql("37.7800000")
      g.address[:lng].should eql("-122.4200000")    
    end
    
    # TODO FIND OUT WHERE THIS DATA COMES FROM AND GET IT WORKING 
    # it "should have a partial address that it's full data doesn't live in WORKS or REGCENTER" do
    #   g = Activity.new(GSA.new(JSON.parse('{"language":"en", "title":"Zumba Punch Card (Adult) - Oct. (5) | Vista, CA, 92084 |", "url":"http://www.active.com/community-services-class/vista-ca/zumba-punch-card-adult-oct-5-2010", "escapedUrl":"http://www.active.com/community-services-class/vista-ca/zumba-punch-card-adult-oct-5-2010", "meta":{"city":"Vista", "assetId":"3ae995d9-5c16-4176-b44e-fa0577644ca4", "substitutionUrl":"vistarecreation/registrationmain.sdi?source=showAsset.sdi&activity_id=4900", "trackbackurl":"http://www.active.com/community-services-class/vista-ca/zumba-punch-card-adult-oct-5-2010", "onlineRegistrationAvailable":"false", "zip":"92084", "sortDate":"2000-10-02", "category":"Activities", "latitude":"33.2000368", "dma":"San Diego", "lastModifiedDate":"2010-09-29", "tags":"2348.321", "lastModifiedDateTime":"2010-09-29 16:46:43.33", "country":"United States of America", "startDate":"2010-10-02", "assetName":"Zumba Punch Card (Adult) -  Oct. (5)", "summary":"People of all ages are falling in love with Zumba, one of the fastest growing dance-based fitness crazes in the country. With Zumbas easy-to-follow dance moves you receive body beautifying benefits while enjoying Latin rhythms including Salsa, Meringue, Cumbia, Reggaeton, even belly dance and hip-hop. Zumba is ", "description":"", "seourl":"http://www.active.com/community-services-class/vista-ca/zumba-punch-card-adult-oct-5-2010", "channel":"Community Services", "splitMediaType":"Class", "mediaType":"Class", "longitude":"-117.2425355", "UpdateDateTime":"8/20/2008 9:03:50 AM", "assetTypeId":"FB27C928-54DB-4ECD-B42F-482FC3C8681F", "state":"California", "keywords":""}, "summary":""}')))
    #   g.address[:name].should eql("City of Vista Recreation")
    #   g.address[:address].should eql("200 Civic Center Dr.")
    #   g.address[:city].should eql("Vista")
    #   g.address[:state].should eql("California")
    #   g.address[:zip].should eql("92084")
    #   g.address[:country].should eql("United States of America")
    #   g.address[:lat].should eql("33.2000368")
    #   g.address[:lng].should eql("-117.2425355")
    # end    

    # USER
      it "should have a nil user email" do
        g = Activity.new(GSA.new(JSON.parse('{"escapedUrl":"http://www.active.com/cycling/san-francisco-ca/seismic-challenge-30-2010","language":"en","title":"Seismic Challenge 3.0 | San Francisco, California 94101 \u003cb\u003e...\u003c/b\u003e","url":"http://www.active.com/cycling/san-francisco-ca/seismic-challenge-30-2010","summary":"","meta":{"startDate":"2010-10-02","eventDate":"2010-10-02T00:00:00-07:00","tag":"event:10","state":"California","eventLongitude":"-122.42","endDate":"2010-10-03","lastModifiedDateTime":"2010-10-04 03:08:51.65","splitMediaType":"Event","locationName":"San Francisco Bay","endTime":"0:00:00","mediaType":"Event","city":"San Francisco","google-site-verification":"","estParticipants":"2000","startTime":"0:00:00","assetId":["35A99FCB-E238-4D78-9205-96179F827CB0","35a99fcb-e238-4d78-9205-96179f827cb0"],"eventId":"1883181","participationCriteria":"All","description":"","longitude":"-122.42","onlineDonationAvailable":"0","substitutionUrl":"1883181","assetName":["Seismic Challenge 3.0","Seismic Challenge 3.0"],"eventURL":"http://greaterthanone.org/events/seismic-challenge/","zip":"94101","contactPhone":"415-487-3053","sortDate":"2000-10-02","eventState":"California","eventLatitude":"37.78","keywords":"Event","onlineMembershipAvailable":"0","dma":"San Francisco - Oakland - San Jose","trackbackurl":"http://www.active.com/cycling/san-francisco-ca/seismic-challenge-30-2010","seourl":"http://www.active.com/cycling/san-francisco-ca/seismic-challenge-30-2010","country":"United States","onlineRegistrationAvailable":"false","category":"Activities","market":"San Francisco - Oakland - San Jose","assetTypeId":"EA4E860A-9DCD-4DAA-A7CA-4A77AD194F65","lastModifiedDate":"2010-10-04","eventZip":"94101","UpdateDateTime":"9/22/2010 11:46:24 AM","latitude":"37.78","channel":"Cycling"}}')))
        g.user.email.should be_nil    
      end
      it "should have a valid user email" do
        g = Activity.new(GSA.new(JSON.parse('{"escapedUrl":"http://www.active.com/cycling/san-francisco-ca/seismic-challenge-30-2010","language":"en","title":"Seismic Challenge 3.0 | San Francisco, California 94101 \u003cb\u003e...\u003c/b\u003e","url":"http://www.active.com/cycling/san-francisco-ca/seismic-challenge-30-2010","summary":"","meta":{"startDate":"2010-10-02","eventDate":"2010-10-02T00:00:00-07:00","tag":"event:10","state":"California","eventLongitude":"-122.42","endDate":"2010-10-03","lastModifiedDateTime":"2010-10-04 03:08:51.65","splitMediaType":"Event","locationName":"San Francisco Bay","endTime":"0:00:00","mediaType":"Event","city":"San Francisco","google-site-verification":"","estParticipants":"2000","startTime":"0:00:00","assetId":["35A99FCB-E238-4D78-9205-96179F827CB0","35a99fcb-e238-4d78-9205-96179f827cb0"],"eventId":"1883181","participationCriteria":"All","description":"","longitude":"-122.42","onlineDonationAvailable":"0","substitutionUrl":"1883181","assetName":["Seismic Challenge 3.0","Seismic Challenge 3.0"],"eventURL":"http://greaterthanone.org/events/seismic-challenge/","zip":"94101","contactPhone":"415-487-3053","sortDate":"2000-10-02","eventState":"California","eventLatitude":"37.78","keywords":"Event","contactEmail":"eventinfo@sfaf.org","onlineMembershipAvailable":"0","dma":"San Francisco - Oakland - San Jose","trackbackurl":"http://www.active.com/cycling/san-francisco-ca/seismic-challenge-30-2010","seourl":"http://www.active.com/cycling/san-francisco-ca/seismic-challenge-30-2010","country":"United States","onlineRegistrationAvailable":"false","category":"Activities","market":"San Francisco - Oakland - San Jose","assetTypeId":"EA4E860A-9DCD-4DAA-A7CA-4A77AD194F65","lastModifiedDate":"2010-10-04","eventZip":"94101","UpdateDateTime":"9/22/2010 11:46:24 AM","latitude":"37.78","channel":"Cycling"}}')))
        g.user.email.should eql("eventinfo@sfaf.org")
      end

    # title
    it "should have a gsa title" do
      @a.title.should eql("2011 Rohto Ironman 70.3 California")
    end
    it "should have a primary title" do
      @a.primary_loaded?.should eql(false)
      @a._title.should eql("2011 Rohto Ironman 70.3 California")
      @a.primary_loaded?.should eql(true)
    end
    it "should have a gsa url" do
      @a.url.should eql("http://www.active.com/triathlon/oceanside-ca/rohto-ironman-703-california-2011")
    end
    it "should have an ats url" do
      @a.ats_loaded?.should eql(false)
      @a._url.should eql("http://www.active.com/triathlon/oceanside-ca/rohto-ironman-703-california-2011")
      @a.ats_loaded?.should eql(true)
    end
    it "should have a gsa categories" do
      @a.categories.should eql(["Triathlon"])
    end
    it "should have an primary source categories" do
      @a.primary_loaded?.should eql(false)
      @a._categories.should eql(["Triathlon"])
      @a.primary_loaded?.should eql(true)
    end
    it "should have a gsa address" do
      @a.primary_loaded?.should eql(false)
      @a.address["address"].should eql("1540 Harbor Drive North")
      @a.primary_loaded?.should eql(false)
    end
    it "should have an primary source address" do
      @a.primary_loaded?.should eql(false)
      @a._address["address"].should eql("1540 Harbor Drive North")
      @a.primary_loaded?.should eql(true)
    end
    it "should have a gsa start_date" do
      @a.primary_loaded?.should eql(false)
      @a.start_date.should be_an_instance_of(DateTime)
      @a.primary_loaded?.should eql(false)
    end
    it "should have an primary source start_date" do
      @a.primary_loaded?.should eql(false)
      @a._start_date.should be_an_instance_of(DateTime)
      @a.primary_loaded?.should eql(true)
    end
    it "should have a gsa start_time" do
      @a.primary_loaded?.should eql(false)
      @a.start_time.should be_an_instance_of(DateTime)
      @a.primary_loaded?.should eql(false)
    end
    it "should have an primary source start_time" do
      @a.primary_loaded?.should eql(false)
      @a._start_time.should be_an_instance_of(DateTime)
      @a.primary_loaded?.should eql(true)
    end

    it "should have a gsa end_date" do
      @a.primary_loaded?.should eql(false)
      @a.end_date.should be_an_instance_of(DateTime)
      @a.primary_loaded?.should eql(false)
    end
    it "should have an primary source end_date" do
      @a.primary_loaded?.should eql(false)
      @a._end_date.should be_an_instance_of(DateTime)
      @a.primary_loaded?.should eql(true)
    end

    it "should have a gsa end_time" do
      @a.primary_loaded?.should eql(false)
      @a.end_time.should be_an_instance_of(DateTime)
      @a.primary_loaded?.should eql(false)
    end
    it "should have an primary source end_time" do
      @a.primary_loaded?.should eql(false)
      @a._end_time.should be_an_instance_of(DateTime)
      @a.primary_loaded?.should eql(true)
    end

    it "should have a gsa category" do
      @a.primary_loaded?.should eql(false)
      @a.category.should eql("Triathlon")
      @a.primary_loaded?.should eql(false)
    end
    it "should have an primary source category" do
      @a.primary_loaded?.should eql(false)
      @a._category.should eql("Triathlon")
      @a.primary_loaded?.should eql(true)
    end

    it "should have a gsa desc" do
      @a.primary_loaded?.should eql(false)
      @a.desc.should eql("")
      @a.primary_loaded?.should eql(false)
    end
    it "should have an primary source desc" do
      @a.primary_loaded?.should eql(false)
      @a._desc.should_not eql("")
      @a.primary_loaded?.should eql(true)
    end

    it "should have a gsa asset_id" do
      @a.primary_loaded?.should eql(false)
      @a.asset_id.should eql("77ACABBD-BA83-4C78-925D-CE49DEDDF20C")
      @a.primary_loaded?.should eql(false)
    end
    it "should have an primary source asset_id" do
      @a.primary_loaded?.should eql(false)
      @a._asset_id.should eql("77acabbd-ba83-4c78-925d-ce49deddf20c")
      @a.primary_loaded?.should eql(true)
    end

    it "should have a gsa asset_type_id" do
      @a.primary_loaded?.should eql(false)
      @a.asset_type_id.should eql("3BF82BBE-CF88-4E8C-A56F-78F5CE87E4C6")
      @a.primary_loaded?.should eql(false)
    end
    it "should have an primary source asset_type_id" do
      @a.primary_loaded?.should eql(false)
      @a._asset_type_id.should eql("EA4E860A-9DCD-4DAA-A7CA-4A77AD194F65")
      @a.primary_loaded?.should eql(true)
    end

  end
end
