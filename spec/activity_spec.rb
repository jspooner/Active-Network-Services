require File.join(File.dirname(__FILE__), %w[spec_helper])
describe "Activity" do
  it "should query for the facet parameter" do
    asset = Active::Activity.per_page(3)
    asset.should be_an_instance_of(Active::Query)
    asset.to_query.should have_param("f=activities")
  end
  
  it "should not query for the facet parameter" do
    asset = Active::Asset.per_page(3)
    asset.should be_an_instance_of(Active::Query)
    asset.to_query.should_not have_param("f=activities")
  end
  
  it "should return an Activity object" do
    result = Active::Asset.find("DD8F427F-6188-465B-8C26-71BBA22D2DB7")
    result.should be_an_instance_of(Active::Activity)
  end
end