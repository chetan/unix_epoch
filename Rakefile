
begin
  require 'rubygems'
  require 'jeweler'
  Jeweler::Tasks.new do |gemspec|
    gemspec.name = "unix_epoch"
    gemspec.summary = "Adds methods to DateTime for dealing with Unix Timestamps"
    gemspec.description = "Adds from_unix_ts and to_unix_ts methods to the DateTime class"
    gemspec.email = "chetan@pixelcop.net"
    gemspec.homepage = "http://github.com/chetan/unix_epoch"
    gemspec.authors = ["Chetan Sarva"]
    gemspec.add_dependency('tzinfo', '>= 0.3.24')
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler not available. Install it with: sudo gem install jeweler"
end

require "rake/testtask"
desc "Run unit tests"
Rake::TestTask.new("test") { |t|
    #t.libs << "test"
    t.ruby_opts << "-rubygems"
    t.pattern = "test/**/*_test.rb"
    t.verbose = false
    t.warning = false
}

require "yard"
YARD::Rake::YardocTask.new("docs") do |t|
end
