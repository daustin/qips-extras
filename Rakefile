require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gemspec|
    gemspec.name = "qips-node-extras"
    gemspec.summary = "Extra scripts for QIPS worker node"
    gemspec.email = "daustin@mail.med.upenn.edu"
    gemspec.homepage = "http://github.com/daustin/qips-extras"
    gemspec.authors = ["David Austin" ,"Andrew Brader"]

    gemspec.add_dependency "erubis", ">=2.6.2"
    gemspec.add_dependency "json", ">=1.2.0"
    gemspec.add_dependency "rest-client", "=1.5.1"
    
    
    Jeweler::GemcutterTasks.new
  end
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end


Dir[File.join(File.dirname(__FILE__), 'tasks/*.rake')].each { |rake| load rake }
