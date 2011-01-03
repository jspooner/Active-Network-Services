# Require the spec helper relative to this file
require File.join(File.dirname(__FILE__), %w[spec_helper])
require File.join(File.dirname(__FILE__), %w[custom_matchers_spec])
require File.join(File.dirname(__FILE__), %w[ .. lib services search])
require File.join(File.dirname(__FILE__), %w[ .. lib services activity])
include Active
include Active::Services


describe Validators do

  it "should find a valid email address" do
    Validators.email("Jeremy.Sheppard@co.kent.de.u").should be_true
    Validators.email("diney.bom-fim_23db@google.com").should be_true
    Validators.email("jspooner@gmail.com").should be_true
    Validators.email("jspooner@ga").should be_false
  end
  
end