# Require the spec helper relative to this file
require File.join(File.dirname(__FILE__), %w[spec_helper])
require File.join(File.dirname(__FILE__), %w[ .. lib services search])
require File.join(File.dirname(__FILE__), %w[ .. lib services activity])
require File.join(File.dirname(__FILE__), %w[ .. lib services IActivity])

# No need to type Britify:: before each call
include Active::Services

describe Activity do
  before(:each) do 
    @valid_attributes = {
      :title => "<b>2011 Walt Disney World\xAE Marathon \u003cb\u003e...\u003c/b\u003e | Lake Buena Vista, Florida <b>...</b>",
      :url => "http://www.active.com/running/lake-buena-vista-fl/walt-disney-world-marathon-2011",
      :language => "en",
      :meta => {
        :trackbackurl                => "http://www.active.com/running/lake-buena-vista-fl/walt-disney-world-marathon-2011",
        :substitutionUrl             => "1820830",
        :assetId                     => ['3584C7D6-14FD-4FD1-BD07-C2A9B2925B6C','3584c7d6-14fd-4fd1-bd07-c2a9b2925b6c'],
        :channel                     => ['action_sports','running'],  
        :city                        => "Lake Buena Vista",
        :latitude                    => "28.39494",
        :category                    => "Activities",
        :zip                         => "32830",
        :eventId                     => "1820830",
        :eventLongitude              => "-81.56783",
        :location                    => "Walt Disney World Resort",
        :eventDate                   => "2011-01-09T05:40:00-08:00",
        :country                     => 'United States',
        :participationCriteria       => 'Adult',
        :locationName                => "Walt Disney World Resort",
        :sortDate                    => "2001-01-09",
        :lastModifiedDate            => "2010-08-17",
        :image1                      => 'http://www.active.com/images/events/hotrace.gif',
        :lastModifiedDateTime        => "2010-08-17 21:00:03.77",
        :eventState                  => "Florida",
        :contactPhone                => "407-938-3398",
        :startDate                   => "2011-01-09",
        :onlineDonationAvailable     => "true",
        :assetTypeId                 => "3BF82BBE-CF88-4E8C-A56F-78F5CE87E4C6",
        :UpdateDateTime              => "8/18/2010 10:16:26 AM",
        :contactEmail                => 'wdw.sports.marathon.endurance@disneysports.com',
        :longitude                   => "-81.56783",
        :description                 => "This is the description",
        :startTime                   => "5:40:00",
        :endTime                     => "5:40:00",
        :eventZip                    => "32830",
        :onlineRegistrationAvailable => "true",
        :onlineMembershipAvailable   => "false",
        :endDate                     => "2011-01-09",
        :keywords                    => "Event",
        :eventLatitude               => "28.39494",
        :state                       => "Florida"
      },      
      :escapedUrl => 'http://www.active.com/running/lake-buena-vista-fl/walt-disney-world-marathon-2011',
      :summary => "This is the summary."
      }
  end
  
  it "should strip out html from the title" do
    a = Activity.new(@valid_attributes)
    a.title.should eql("2011 Walt Disney World Marathon")
  end
  
  it "should strip out unicode from the title"
  
  it "should use the first group if title contains pipes." 
  
  it "should have 2 channels" do
    a = Activity.new(@valid_attributes)
    a.categories.should be_an_instance_of(Array)
    a.should have(2).categories
  end
  
  it "should be a valid activity" do
    a = Activity.new(@valid_attributes)
    a.url.should eql("http://www.active.com/running/lake-buena-vista-fl/walt-disney-world-marathon-2011")
    a.categories.include?("action_sports").should be_true
    a.asset_id.should eql("3584C7D6-14FD-4FD1-BD07-C2A9B2925B6C")
    
    a.title.should_not be_nil                      
    a.start_date.should_not be_nil                 
    a.end_date.should_not be_nil                   
    a.categories.should_not be_nil                   
    a.desc.should_not be_nil                
    a.start_time.should_not be_nil                 
    a.end_time.should_not be_nil    

    a.start_date.should be_a_kind_of(Date)
    a.end_date.should be_a_kind_of(Date)

    a.address.should_not be_nil
    a.address[:city].should_not be_nil               
    a.address[:state].should_not be_nil               
    a.address[:country].should_not be_nil               
    a.address[:zip].should_not be_nil               
    a.address[:lat].should_not be_nil               
    a.address[:lng].should_not be_nil               
    a.address[:name].should_not be_nil               
  end
  
  describe "Activity url" do
    it "should have a valid seo url: type 1" do
      a = Activity.new({ :url => "http://active.com/foo.php", :meta => { :trackbackurl => "http://active.com/running/funrun", :seourl => "http://foo" } })
      a.url.should == "http://active.com/running/funrun"
    end
    it "should have a valid seo url: type 2" do
      a = Activity.new({ :url => "http://active.com/foo.php", :meta => { :trackbackurl => "http://active.com/running/funrun" } })
      a.url.should == "http://active.com/running/funrun"
    end
    it "should have a valid seo url: type 3" do
      a = Activity.new({ :url => "http://active.com/foo.php" })
      a.url.should == "http://active.com/foo.php"
    end
  end
  
  describe  "ATS data fetch" do
    it "should retrive the ats data"
    it "should store the date when ats was"
  end
  
  describe "ActiveNet data fetch" do
    # todo get a list of ActiveNet ids
    # assetTypeId: FB27C928-54DB-4ECD-B42F-482FC3C8681F
    # assetTypeName: ActiveNet
    # assetId: 4C2C70F1-9D53-4ECA-A04C-68A76C3A53F4
    # assetId: 34DB5609-6697-400D-8C52-0305D479C9C1
    # assetId: 65B56E1A-5C3E-4D9B-8EA6-0417C07E5956
    
    
    it "should retrive data from ActiveNet" do
      # a = Activity.new({})
      # a.should receive al call to a.get_ats_data
      # a.rawdata.should be a freaking hash
      pending
    end
    
    describe "Lazy loading of params" do
      it "should call ATS when only asset_id is set" do
        ATS.should_receive(:find_by_id).with("A9EF9D79-F859-4443-A9BB-91E1833DF2D5").once
        a = Activity.find_by_asset_id(:asset_id => "A9EF9D79-F859-4443-A9BB-91E1833DF2D5")
      end
      it "should save the asset_id" do
        a = Activity.find_by_asset_id(:asset_id => "A9EF9D79-F859-4443-A9BB-91E1833DF2D5")
        a.asset_id.should == "A9EF9D79-F859-4443-A9BB-91E1833DF2D5"      
        a.title.should == "Fitness, Pilates  Mat Class (16 Yrs. &amp; Up)"  
      end
      it "should thorw an ActivityFindError if no record is found" do
        lambda { Activity.find_by_asset_id( :asset_id => "666" ) }.should raise_error(ActivityFindError)                         
      end
      
      
      it "should save the asset_id and type" do        
        a = Activity.find_by_asset_id(:asset_id => "A9EF9D79-F859-4443-A9BB-91E1833DF2D5", :asset_type_id => "EA4E860A-9DCD-4DAA-A7CA-4A77AD194F65")
        a.asset_id.should == "A9EF9D79-F859-4443-A9BB-91E1833DF2D5"        
        a.asset_type_id.should == "EA4E860A-9DCD-4DAA-A7CA-4A77AD194F65"
      end
      it "should obtain the asset_type_id if it wasn't provided" do
        a = Activity.find_by_asset_id(:asset_id => "A9EF9D79-F859-4443-A9BB-91E1833DF2D5")
        a.asset_type_id.should == "EA4E860A-9DCD-4DAA-A7CA-4A77AD194F65"
      end
      it "should have an event closing date" do
        # a.eventCloseDate.should == "2010-09-13T00:00:00-07:00"
      end
      it "should return the start time" do
        # mock 
        # a = Activity.new({})
        # a.start_time.should == 11:00 am
        pending
      end
    end 
  end
  
  
end










