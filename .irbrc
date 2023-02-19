begin
  project = File.basename __dir__
  require project
  klass = project.split('_').map{_1.capitalize}.join
  version = eval "#{klass}::VERSION"
  message = "### #{klass}:#{version} Ruby:#{RUBY_VERSION} ###"
rescue Exception
  message = $!.message
end
require 'irbtools/configure'
Irbtools.welcome_message = message
Irbtools.start
