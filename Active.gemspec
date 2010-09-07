# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{Active}
  s.version = "0.0.5"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Jonathan Spooner, Brian Levine"]
  s.date = %q{2010-09-02}
  s.default_executable = %q{Active}
  s.description = %q{Search api for Active Network}
  s.email = %q{jspooner [at] gmail.com}
  s.executables = ["Active"]
  s.extra_rdoc_files = ["History.txt", "README.txt", "bin/Active", "version.txt"]
  s.files = [".bnsignore", "Active.gemspec", "History.txt", "README.txt", "Rakefile", "bin/Active", "lib/Active.rb", "lib/services/activity.rb", "lib/services/search.rb", "spec/.DS_Store", "spec/Active_spec.rb", "spec/activity_spec.rb", "spec/search_spec.rb", "spec/spec_helper.rb", "test/test_Active.rb", "version.txt"]
  s.homepage = %q{http://developer.active.com/docs/Activecom_Search_API_Reference}
  s.rdoc_options = ["--main", "README.txt"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{Active}
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{Search api for Active Network}
  s.test_files = ["test/test_Active.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<bones>, [">= 3.4.7"])
    else
      s.add_dependency(%q<bones>, [">= 3.4.7"])
    end
  else
    s.add_dependency(%q<bones>, [">= 3.4.7"])
  end
end
