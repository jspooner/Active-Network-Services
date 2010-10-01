# Require the spec helper relative to this file
require File.join(File.dirname(__FILE__), %w[spec_helper])
require File.join(File.dirname(__FILE__), %w[custom_matchers_spec])
require File.join(File.dirname(__FILE__), %w[ .. lib services search])
require File.join(File.dirname(__FILE__), %w[ .. lib services activity])
require File.join(File.dirname(__FILE__), %w[ .. lib services reg_center])
include Active::Services

describe RegCenter do
  before(:each) do 
#    @valid_id = "1802851"
    @valid_id = "1877942"
#    @valid_id = "1889826"
#    @valid_id = "1847738"
# <soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><soap:Body><getAssetMetadataResponse xmlns="http://api.asset.services.active.com"><out xmlns="http://api.asset.services.active.com">&lt;importSource>&lt;asset row="1" destinationID="">&lt;isSearchable>true&lt;/isSearchable>&lt;assetId>BF304447-0052-4466-A044-68D1459C5068&lt;/assetId>&lt;assetTypeId>EA4E860A-9DCD-4DAA-A7CA-4A77AD194F65&lt;/assetTypeId>&lt;substitutionUrl>1886328&lt;/substitutionUrl>&lt;assetName>Excellence in Writing&lt;/assetName>&lt;category>Activities&lt;/category>&lt;channel>Not Specified&lt;/channel>&lt;mediaType>Recware Activities&lt;/mediaType>&lt;searchWeight>1&lt;/searchWeight>&lt;zip>92027&lt;/zip>&lt;city>Escondido&lt;/city>&lt;state>California&lt;/state>&lt;country>United States&lt;/country>&lt;startDate>2010-09-07&lt;/startDate>&lt;startTime>15:30:00&lt;/startTime>&lt;endDate>2010-09-07&lt;/endDate>&lt;endTime>15:30:00&lt;/endTime>&lt;participationCriteria>All&lt;/participationCriteria>&lt;onlineRegistrationAvailable>true&lt;/onlineRegistrationAvailable>&lt;onlineDonationAvailable>0&lt;/onlineDonationAvailable>&lt;onlineMembershipAvailable>0&lt;/onlineMembershipAvailable>&lt;avgUserRating/>&lt;userCommentText/>&lt;image1>http://www.active.com/images/events/hotrace.gif&lt;/image1>&lt;contactEmail>recreation@escondido.org&lt;/contactEmail>&lt;contactPhone>760-839-4691&lt;/contactPhone>&lt;eventResults/>&lt;location>Grove Room - East Valley Community Center&lt;/location>&lt;contactName>Escondido Community Services Department&lt;/contactName>&lt;market>San Diego&lt;/market>&lt;trackbackurl>http://www.active.com/page/Event_Details.htm?event_id=1886328&amp;amp;assetId=BF304447-0052-4466-A044-68D1459C5068&lt;/trackbackurl>&lt;seourl>http://www.active.com/not-specified-recware-activities/escondido-ca/excellence-in-writing-2010&lt;/seourl>&lt;dma>San Diego&lt;/dma>&lt;longitude>-117.0864&lt;/longitude>&lt;latitude>33.11921&lt;/latitude>&lt;/asset>&lt;/importSource></out></getAssetMetadataResponse></soap:Body></soap:Envelope>

  end
  it "should set find by id" do
    a = RegCenter.find_by_id(@valid_id)
    a.data.should_not be_nil
    a.title.should eql("Realistic Drawing (6-12 Yrs.)")
  end
  it "should set the asset_type_id" do
    RegCenter.find_by_id(@valid_id).asset_type_id.should_not be_nil
  end
  it "should thorw an RegCenterError if no record is found" do
    lambda { RegCenter.find_by_id( "666" ) }.should raise_error(RegCenterError)                         
  end
  it "should get the API metadata" do
    a = RegCenter.find_by_id(@valid_id)
    a.data["event"].should_not be_nil
  end
  it "should have an address Hash" do
    a = RegCenter.find_by_id(@valid_id)
    a.address.should be_an_instance_of(HashWithIndifferentAccess)
  end
  it "should have a desc String" do
    a = RegCenter.find_by_id(@valid_id)
    a.desc.should be_an_instance_of(String)
  end
  it "should cleanup title" do
    a = RegCenter.find_by_id(@valid_id)
    a.title.should_not include("\r")
  end
  # it "should have a primary category" do
  #   a = RegCenter.find_by_id(@valid_id)
  #   puts a.primary_category
  #   a.primary_category.should_not be_nil
  # end
  it "should have a title String" do
    a = RegCenter.find_by_id(@valid_id)
    a.title.should be_an_instance_of(String)
  end
  it "should have a categories array" do
    a = RegCenter.find_by_id(@valid_id)
    puts a.categories.inspect
    a.categories.should be_an_instance_of(Array)
  end
  # it "should have a category" do
  #   a = RegCenter.find_by_id(@valid_id)
  #   a.category.should be_an_instance_of(String)
  # end
  it "should have a start_date DateTime" do
    a = RegCenter.find_by_id(@valid_id)
    puts a.start_date
    a.start_date.should be_an_instance_of(DateTime)
  end
  it "should have a start_time DateTime" do
    a = RegCenter.find_by_id(@valid_id)
    a.start_time.should be_an_instance_of(DateTime)
  end
  
  
end
