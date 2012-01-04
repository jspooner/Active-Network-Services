require File.join(File.dirname(__FILE__), %w[spec_helper])
describe "Search" do
  describe "Asset Accessors" do
    
    describe "invalid UTF-8 byte sequences" do
      # TODO: Test pipe separately from UTF-8
      it "should gracefully handle invalid UTF-8 byte sequences in the title" do
        asset = Active::Asset.new()
        asset['title'] = "one | \xB7 two"
        asset.title.should eql("one")
      end
    end
    
    describe "HTML and special character sanitizing" do
      it "should convert HTML special characters in the title" do
        asset = Active::Asset.new()
        asset['title'] = "one &amp; two"
        asset.title.should eql("one & two")
      end
      it "should remove HTML tags from the title" do
        asset = Active::Asset.new()
        asset['title'] = "one <b>two</b>"
        asset.title.should eql("one two")
      end
      it "should remove HTML tags from the description" do
        asset = Active::Asset.new({"meta" => { "summary"=>"one <b>two</b>" }})
        asset.description.should eql("one two")
      end
    end
    
    describe "Address and Location" do
      it "should return an address if one exists in meta" do
        asset = Active::Asset.new({"meta" => { "address"=>"123 Main St" }})
        asset.address.should eql("123 Main St")
      end
      it "should return location if no address is present" do
        asset = Active::Asset.new({"meta" => { "location"=>"123 Main St" }})
        asset.address.should eql("123 Main St")
      end
      it "should return city, state if no location or address" do
        asset = Active::Asset.new({"meta" => { "city"=>"Brooklyn", "state"=>"New York" }})
        asset.address.should eql("Brooklyn, New York")
      end
    end
    
  end
end
