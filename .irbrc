# Project-specific .irbrc file

# In order for this file to be picked up automatically by irb, you need to add
# the following code (or equivalent) to your own ~/.irbrc file:

  # if Dir.pwd != File.expand_path("~")
  #   local_irbrc = File.expand_path '.irbrc'
  #   if File.exist? local_irbrc
  #     puts "Loading #{local_irbrc}"
  #     load local_irbrc
  #   end
  # end

# When irb is started within this project folder (read: during gem development)
# this file will add lib/ to the load_path and require the gem.

$LOAD_PATH.unshift File.expand_path(File.join(File.dirname(__FILE__), 'lib'))
require 'Active'
