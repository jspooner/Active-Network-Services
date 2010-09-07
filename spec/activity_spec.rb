# Require the spec helper relative to this file
require File.join(File.dirname(__FILE__), %w[spec_helper])
require File.join(File.dirname(__FILE__), %w[ .. lib services search])
require File.join(File.dirname(__FILE__), %w[ .. lib services activity])

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
  
  it "should use the first group if title contains pipes." do
    
  end
  
  it "should be a valid activity" do
    a = Activity.new(@valid_attributes)
    a.url.should eql("http://www.active.com/running/lake-buena-vista-fl/walt-disney-world-marathon-2011")
    a.category.should eql("action_sports")
    a.asset_id.should eql("3584C7D6-14FD-4FD1-BD07-C2A9B2925B6C")
    
    a.title.should_not be_nil                      
    a.start_date.should_not be_nil                 
    a.end_date.should_not be_nil                   
    a.category.should_not be_nil                   
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
    
    # a.onlineDonationAvailable.should_not be_nil        
    # a.onlineRegistrationAvailable.should_not be_nil
    # a.onlineMembershipAvailable.should_not be_nil  
    
  end
  
  
end
