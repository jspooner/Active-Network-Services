# Require the spec helper relative to this file
require File.join(File.dirname(__FILE__), %w[spec_helper])
require File.join(File.dirname(__FILE__), %w[custom_matchers_spec])
require File.join(File.dirname(__FILE__), %w[ .. lib services search])
require File.join(File.dirname(__FILE__), %w[ .. lib services activity])
require File.join(File.dirname(__FILE__), %w[ .. lib services ats])
require File.join(File.dirname(__FILE__), %w[ .. lib services address])
include Active::Services

describe ATS do
  before(:each) do 
#    @valid_id = "A9EF9D79-F859-4443-A9BB-91E1833DF2D5"
    @valid_id="61BB7D71-EC01-46B8-A601-38CA1C9AE893"
    @reg_center_id = "D9A22F33-8A14-4175-8D5B-D11578212A98"
  end
  it "should set find by id" do
    a = ATS.find_by_id(@valid_id)
    a.asset_id.should == @valid_id
  end
  it "should get the asset_type_id" do
    ATS.find_by_id(@valid_id).asset_type_id.should_not be_nil
  end
  it "should thorw an ATSError if no record is found" do
    lambda { ATS.find_by_id( "666" ) }.should raise_error(ATSError)                         
  end
  it "should get the asset metadata" do
    ATS.get_asset_metadata(@valid_id).should_not be_nil
  end
  it "should load the asset metadata into @data" do
    a = ATS.find_by_id(@valid_id)
    a.load_metadata
    a.data["isSearchable"].should_not be_nil
  end
  it "should load the lazy the asset metadata" do
    a = ATS.find_by_id(@valid_id)
    puts a.url
    a.start_date.should_not be_nil
  end
  # works differently in current implementation
  # it "should only load metadata once" do
  #   a = ATS.find_by_id(@valid_id)
  #   puts a.url
  #   puts a.address
  #   ATS.should_receive(:load_metadata).once
  # end
  it "should have an address Hash" do
    a = ATS.find_by_id(@valid_id)
    a.address.should be_an_instance_of(HashWithIndifferentAccess)
  end
  it "should have address data" do
    r = ATS.new({"trackbackurl"=>"http://www.active.com/page/Event_Details.htm?event_id=1819585&assetId=61BB7D71-EC01-46B8-A601-38CA1C9AE893", "contactName"=>"DSE Runners", "city"=>"San Francisco", "substitutionUrl"=>"1819585", "assetId"=>"61BB7D71-EC01-46B8-A601-38CA1C9AE893", "destinationID"=>"", "latitude"=>"37.77029", "location"=>"Lindley Meadow near Spreckles Lake", "userCommentText"=>nil, "zip"=>"94117", "category"=>"Activities", "dma"=>"San Francisco - Oakland - San Jose", "participationCriteria"=>"Adult", "country"=>"United States", "searchWeight"=>"1", "isSearchable"=>"true", "image1"=>"http://www.active.com/images/events/hotrace.gif", "row"=>"1", "contactPhone"=>"415-978-0837", "startDate"=>"2010-09-12", "market"=>"San Francisco - Oakland - San Jose", "avgUserRating"=>nil, "onlineDonationAvailable"=>"0", "seourl"=>"http://www.active.com/running/san-francisco-ca/speedway-meadow-cross-country-4m-2010", "channel"=>["Running", "Running\\Cross Country"], "assetName"=>"Speedway Meadow Cross Country 4M", "assetTypeId"=>"EA4E860A-9DCD-4DAA-A7CA-4A77AD194F65", "longitude"=>"-122.4411", "eventResults"=>nil, "contactEmail"=>"dserunclub@aol.com", "endTime"=>"9:00:00", "startTime"=>"9:00:00", "mediaType"=>"Event", "onlineMembershipAvailable"=>"0", "onlineRegistrationAvailable"=>"true", "endDate"=>"2010-09-12", "eventURL"=>"http://www.dserunners.com", "estParticipants"=>"175", "state"=>"California"})
    puts r.address.inspect
    r.address["name"].should eql "Lindley Meadow near Spreckles Lake"
    r.address["address"].should eql nil
    r.address["city"].should eql "San Francisco"
    r.address["state"].should eql "California"
    r.address["zip"].should eql "94117"
    r.address["lat"].should eql "37.77029"
    r.address["lng"].should eql "-122.4411"
    r.address["country"].should eql "United States"
  end

  it "should nil empty data" do
    r = ATS.new({"trackbackurl"=>"http://www.active.com/page/Event_Details.htm?event_id=1819585&assetId=61BB7D71-EC01-46B8-A601-38CA1C9AE893", "contactName"=>"DSE Runners", "city"=>"San Francisco", "substitutionUrl"=>"1819585", "assetId"=>"61BB7D71-EC01-46B8-A601-38CA1C9AE893", "destinationID"=>"", "latitude"=>"37.77029", "location"=>"  ", "userCommentText"=>nil, "zip"=>"94117", "category"=>"Activities", "dma"=>"San Francisco - Oakland - San Jose", "participationCriteria"=>"Adult", "country"=>"United States", "searchWeight"=>"1", "isSearchable"=>"true", "image1"=>"http://www.active.com/images/events/hotrace.gif", "row"=>"1", "contactPhone"=>"415-978-0837", "startDate"=>"2010-09-12", "market"=>"San Francisco - Oakland - San Jose", "avgUserRating"=>nil, "onlineDonationAvailable"=>"0", "seourl"=>"http://www.active.com/running/san-francisco-ca/speedway-meadow-cross-country-4m-2010", "channel"=>["Running", "Running\\Cross Country"], "assetName"=>"Speedway Meadow Cross Country 4M", "assetTypeId"=>"EA4E860A-9DCD-4DAA-A7CA-4A77AD194F65", "longitude"=>"-122.4411", "eventResults"=>nil, "contactEmail"=>"dserunclub@aol.com", "endTime"=>"9:00:00", "startTime"=>"9:00:00", "mediaType"=>"Event", "onlineMembershipAvailable"=>"0", "onlineRegistrationAvailable"=>"true", "endDate"=>"2010-09-12", "eventURL"=>"http://www.dserunners.com", "estParticipants"=>"175", "state"=>"California"})
    r.address["name"].should be_nil
  end
  it "should nil bad zip code data" do
    r = ATS.new({"trackbackurl"=>"http://www.active.com/page/Event_Details.htm?event_id=1819585&assetId=61BB7D71-EC01-46B8-A601-38CA1C9AE893", "contactName"=>"DSE Runners", "city"=>"San Francisco", "substitutionUrl"=>"1819585", "assetId"=>"61BB7D71-EC01-46B8-A601-38CA1C9AE893", "destinationID"=>"", "latitude"=>"37.77029", "location"=>"Lindley Meadow near Spreckles Lake", "userCommentText"=>nil, "zip"=>"94117-123456", "category"=>"Activities", "dma"=>"San Francisco - Oakland - San Jose", "participationCriteria"=>"Adult", "country"=>"United States", "searchWeight"=>"1", "isSearchable"=>"true", "image1"=>"http://www.active.com/images/events/hotrace.gif", "row"=>"1", "contactPhone"=>"415-978-0837", "startDate"=>"2010-09-12", "market"=>"San Francisco - Oakland - San Jose", "avgUserRating"=>nil, "onlineDonationAvailable"=>"0", "seourl"=>"http://www.active.com/running/san-francisco-ca/speedway-meadow-cross-country-4m-2010", "channel"=>["Running", "Running\\Cross Country"], "assetName"=>"Speedway Meadow Cross Country 4M", "assetTypeId"=>"EA4E860A-9DCD-4DAA-A7CA-4A77AD194F65", "longitude"=>"-122.4411", "eventResults"=>nil, "contactEmail"=>"dserunclub@aol.com", "endTime"=>"9:00:00", "startTime"=>"9:00:00", "mediaType"=>"Event", "onlineMembershipAvailable"=>"0", "onlineRegistrationAvailable"=>"true", "endDate"=>"2010-09-12", "eventURL"=>"http://www.dserunners.com", "estParticipants"=>"175", "state"=>"California"})
    r.address["zip"].should be_nil
  end

  it "should fix state abbreviations" do
    r = ATS.new({"trackbackurl"=>"http://www.active.com/page/Event_Details.htm?event_id=1819585&assetId=61BB7D71-EC01-46B8-A601-38CA1C9AE893", "contactName"=>"DSE Runners", "city"=>"San Francisco", "substitutionUrl"=>"1819585", "assetId"=>"61BB7D71-EC01-46B8-A601-38CA1C9AE893", "destinationID"=>"", "latitude"=>"37.77029", "location"=>"Lindley Meadow near Spreckles Lake", "userCommentText"=>nil, "zip"=>"94117", "category"=>"Activities", "dma"=>"San Francisco - Oakland - San Jose", "participationCriteria"=>"Adult", "country"=>"United States", "searchWeight"=>"1", "isSearchable"=>"true", "image1"=>"http://www.active.com/images/events/hotrace.gif", "row"=>"1", "contactPhone"=>"415-978-0837", "startDate"=>"2010-09-12", "market"=>"San Francisco - Oakland - San Jose", "avgUserRating"=>nil, "onlineDonationAvailable"=>"0", "seourl"=>"http://www.active.com/running/san-francisco-ca/speedway-meadow-cross-country-4m-2010", "channel"=>["Running", "Running\\Cross Country"], "assetName"=>"Speedway Meadow Cross Country 4M", "assetTypeId"=>"EA4E860A-9DCD-4DAA-A7CA-4A77AD194F65", "longitude"=>"-122.4411", "eventResults"=>nil, "contactEmail"=>"dserunclub@aol.com", "endTime"=>"9:00:00", "startTime"=>"9:00:00", "mediaType"=>"Event", "onlineMembershipAvailable"=>"0", "onlineRegistrationAvailable"=>"true", "endDate"=>"2010-09-12", "eventURL"=>"http://www.dserunners.com", "estParticipants"=>"175", "state"=>"CA"})
    r.address["state"].should eql "California"
  end

  it "should have a nil user email" do
    r = ATS.new({"trackbackurl"=>"http://www.active.com/page/Event_Details.htm?event_id=1819585&assetId=61BB7D71-EC01-46B8-A601-38CA1C9AE893", "contactName"=>"DSE Runners", "city"=>"San Francisco", "substitutionUrl"=>"1819585", "assetId"=>"61BB7D71-EC01-46B8-A601-38CA1C9AE893", "destinationID"=>"", "latitude"=>"37.77029", "location"=>"  ", "userCommentText"=>nil, "zip"=>"94117", "category"=>"Activities", "dma"=>"San Francisco - Oakland - San Jose", "participationCriteria"=>"Adult", "country"=>"United States", "searchWeight"=>"1", "isSearchable"=>"true", "image1"=>"http://www.active.com/images/events/hotrace.gif", "row"=>"1", "contactPhone"=>"415-978-0837", "startDate"=>"2010-09-12", "market"=>"San Francisco - Oakland - San Jose", "avgUserRating"=>nil, "onlineDonationAvailable"=>"0", "seourl"=>"http://www.active.com/running/san-francisco-ca/speedway-meadow-cross-country-4m-2010", "channel"=>["Running", "Running\\Cross Country"], "assetName"=>"Speedway Meadow Cross Country 4M", "assetTypeId"=>"EA4E860A-9DCD-4DAA-A7CA-4A77AD194F65", "longitude"=>"-122.4411", "eventResults"=>nil,  "endTime"=>"9:00:00", "startTime"=>"9:00:00", "mediaType"=>"Event", "onlineMembershipAvailable"=>"0", "onlineRegistrationAvailable"=>"true", "endDate"=>"2010-09-12", "eventURL"=>"http://www.dserunners.com", "estParticipants"=>"175", "state"=>"California"})
    r.user.email.should be_nil    
  end
  it "should have a nil user email when the email is not valid" do
    r = ATS.new({"trackbackurl"=>"http://www.active.com/page/Event_Details.htm?event_id=1819585&assetId=61BB7D71-EC01-46B8-A601-38CA1C9AE893", "contactName"=>"DSE Runners", "city"=>"San Francisco", "substitutionUrl"=>"1819585", "assetId"=>"61BB7D71-EC01-46B8-A601-38CA1C9AE893", "destinationID"=>"", "latitude"=>"37.77029", "location"=>"  ", "userCommentText"=>nil, "zip"=>"94117", "category"=>"Activities", "dma"=>"San Francisco - Oakland - San Jose", "participationCriteria"=>"Adult", "country"=>"United States", "searchWeight"=>"1", "isSearchable"=>"true", "image1"=>"http://www.active.com/images/events/hotrace.gif", "row"=>"1", "contactPhone"=>"415-978-0837", "startDate"=>"2010-09-12", "market"=>"San Francisco - Oakland - San Jose", "avgUserRating"=>nil, "onlineDonationAvailable"=>"0", "seourl"=>"http://www.active.com/running/san-francisco-ca/speedway-meadow-cross-country-4m-2010", "channel"=>["Running", "Running\\Cross Country"], "assetName"=>"Speedway Meadow Cross Country 4M", "assetTypeId"=>"EA4E860A-9DCD-4DAA-A7CA-4A77AD194F65", "longitude"=>"-122.4411", "eventResults"=>nil, "contactPhone"=>"dserunclubaolcom", "endTime"=>"9:00:00", "startTime"=>"9:00:00", "mediaType"=>"Event", "onlineMembershipAvailable"=>"0", "onlineRegistrationAvailable"=>"true", "endDate"=>"2010-09-12", "eventURL"=>"http://www.dserunners.com", "estParticipants"=>"175", "state"=>"California"})
    r.user.email.should be_nil
  end
  it "should have a valid user email" do
    r = ATS.new({"trackbackurl"=>"http://www.active.com/page/Event_Details.htm?event_id=1819585&assetId=61BB7D71-EC01-46B8-A601-38CA1C9AE893", "contactName"=>"DSE Runners", "city"=>"San Francisco", "substitutionUrl"=>"1819585", "assetId"=>"61BB7D71-EC01-46B8-A601-38CA1C9AE893", "destinationID"=>"", "latitude"=>"37.77029", "location"=>"  ", "userCommentText"=>nil, "zip"=>"94117", "category"=>"Activities", "dma"=>"San Francisco - Oakland - San Jose", "participationCriteria"=>"Adult", "country"=>"United States", "searchWeight"=>"1", "isSearchable"=>"true", "image1"=>"http://www.active.com/images/events/hotrace.gif", "row"=>"1", "contactPhone"=>"415-978-0837", "startDate"=>"2010-09-12", "market"=>"San Francisco - Oakland - San Jose", "avgUserRating"=>nil, "onlineDonationAvailable"=>"0", "seourl"=>"http://www.active.com/running/san-francisco-ca/speedway-meadow-cross-country-4m-2010", "channel"=>["Running", "Running\\Cross Country"], "assetName"=>"Speedway Meadow Cross Country 4M", "assetTypeId"=>"EA4E860A-9DCD-4DAA-A7CA-4A77AD194F65", "longitude"=>"-122.4411", "eventResults"=>nil, "contactEmail"=>"dserunclub@aol.com", "endTime"=>"9:00:00", "startTime"=>"9:00:00", "mediaType"=>"Event", "onlineMembershipAvailable"=>"0", "onlineRegistrationAvailable"=>"true", "endDate"=>"2010-09-12", "eventURL"=>"http://www.dserunners.com", "estParticipants"=>"175", "state"=>"California"})
    r.user.email.should eql("dserunclub@aol.com")
  end


  it "should have a startDate Date" do
    a = ATS.find_by_id(@valid_id)
    puts a.start_date.class
    a.start_date.should be_an_instance_of(DateTime)
  end
  it "should have a title String" do
    a = ATS.find_by_id(@valid_id)
    a.title.should be_an_instance_of(String)
  end
##########  
  it "should have an address" do
    a = ATS.new('<importSource><asset row="1" destinationID=""><isSearchable>true</isSearchable><assetTypeId>FB27C928-54DB-4ECD-B42F-482FC3C8681F</assetTypeId><substitutionUrl>vistarecreation/registrationmain.sdi?source=showAsset.sdi&amp;activity_id=4900</substitutionUrl><assetName>Zumba Punch Card (Adult) -  Oct. (5)</assetName><category>Activities</category><channel>Community Services</channel><mediaType>Class</mediaType><searchWeight>1</searchWeight><summary>People of all ages are falling in love with Zumba, one of the fastest growing dance-based fitness crazes in the country. With Zumbas easy-to-follow dance moves you receive body beautifying benefits while enjoying Latin rhythms including Salsa, Meringue, Cumbia, Reggaeton, even belly dance and hip-hop. Zumba is sure to put the fun back into your work outs!</summary><zip>92084</zip><city>Vista</city><state>California</state><country>United States of America</country><startDate>2010-10-02</startDate><onlineRegistrationAvailable>false</onlineRegistrationAvailable><tags>2348.321</tags><assetId>3ae995d9-5c16-4176-b44e-fa0577644ca4</assetId><trackbackurl>http://www.active.com/page/event_details_an.htm?type=activenet&amp;subUrl=vistarecreation/registrationmain.sdi?source=showAsset.sdi&amp;activity_id=4900</trackbackurl><seourl>http://www.active.com/community-services-class/vista-ca/zumba-punch-card-adult-oct-5-2010</seourl><dma>San Diego</dma><longitude>-117.2425355</longitude><latitude>33.2000368</latitude></asset></importSource>')
    a.data.should_not be_nil
  end
  
end
