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
    ATS.find_by_id(@valid_id).asset_id_type.should_not be_nil
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
  it "should only load metadata once" do
    a = ATS.find_by_id(@valid_id)
    puts a.url
    puts a.address
    ATS.should_receive(:load_metadata).once
  end
  it "should have an address Hash" do
    a = ATS.find_by_id(@valid_id)
    a.address.should be_an_instance_of(HashWithIndifferentAccess)
  end
  it "should have a startDate Date" do
    a = ATS.find_by_id(@valid_id)
    a.start_date.should be_an_instance_of(Date)
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
