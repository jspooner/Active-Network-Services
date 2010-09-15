
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
  gem.extras[:post_install_message] = <<-MSG
  --------------------------
  Welcome to Active Network
  --------------------------
  MSG
  depend_on  'savon'
  depend_on  'fake_web'
}

