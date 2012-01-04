begin
  require 'bundler/gem_tasks'
rescue LoadError
  abort '### Please install the "bundler" gem ###'
end

begin
  require 'metric_fu'
rescue LoadError
  pass
end


require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec) do |t|
  # t.pattern = 'spec/search_spec.rb'
end

task :default => :spec
