# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "active/version"

Gem::Specification.new do |s|
  s.name        = "Active"
  s.version     = Active::VERSION
  s.date        = "2011-10-13"
  s.authors     = ["Jonathan Spooner, Marc Leglise"]
  s.email       = ["jspooner@gmail.com"]
  s.homepage    = "http://developer.active.com/docs/Activecom_Search_API_Reference"
  s.summary     = %q{Search api for Active Network}
  s.description = %q{Search api for Active Network}

  s.rubyforge_project = "Active"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  
  s.extra_rdoc_files = ["History.txt", "README.md"]
  s.rdoc_options = ["--main", "README.md"]
  
  s.add_dependency "json", "~> 1"
  s.add_dependency "hashie", "~> 1"
  s.add_dependency "activesupport", "> 3"
  s.add_dependency "htmlentities", "> 4"
  # s.add_dependency "savon", "= 0.7.9"
  # s.add_dependency "dalli", "= 0.9.8"
  
  s.add_development_dependency "rspec", "~> 2"
  s.add_development_dependency "metric_fu", "~> 2"
  # s.add_development_dependency "mocha", "= 0.9.8"
end
