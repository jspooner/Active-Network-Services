require File.expand_path(File.join(File.dirname(__FILE__), %w[.. lib Active]))
require 'date'

RSpec.configure do |config|
  # == Mock Framework
  #
  # RSpec uses it's own mocking framework by default. If you prefer to
  # use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr
end

RSpec::Matchers.define :have_param do |expected|
  match do |actual|
    actual.include?(expected)
  end

  failure_message_for_should do |actual|
    "expected #{actual.inspect} to have param #{expected.inspect}, but it didn't"
  end

  failure_message_for_should_not do |actual|
    "expected #{actual.inspect} not to have param #{expected.inspect}, but it did"
  end

  description do
    "have param #{expected}"
  end
end

def open_url(str)
  system("open \"#{str}\"")
end
