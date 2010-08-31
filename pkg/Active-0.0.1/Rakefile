
begin
  require 'bones'
rescue LoadError
  abort '### Please install the "bones" gem ###'
end

task :default => 'test:run'
task 'gem:release' => 'test:run'

Bones {
  name  'Active'
  authors  'Jonathan Spooner, Brian Levine'
  email    'jspooner [at] gmail.com'
  url      'http://developer.active.com/docs/Activecom_Search_API_Reference'
}

