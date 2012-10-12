# encoding: utf-8

require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

require 'jeweler'
Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  gem.name = "gangsta"
  gem.homepage = "http://github.com/jeffgran/gangsta"
  gem.license = "MIT"
  gem.summary = %Q{Gangsta: cuz I repreZENT!}
  gem.description = %Q{Declarative representation DSL, makes classes serializable to/from XML, JSON, RDF, and whatever else you want.}
  gem.email = "jeff.gran@openlogic.com"
  gem.authors = ["Jeff Gran"]
  # dependencies defined in Gemfile
  gem.add_dependency 'blankslate', "~> 3.1"
  gem.add_dependency 'activesupport', "~> 3"
  gem.add_dependency 'rdf', "~> 0.3"
  gem.add_dependency 'rdf-rdfxml', "~> 0.3"
  gem.add_dependency 'nokogiri', "~> 1.5"
  gem.add_dependency 'jsonify', '~> 0.4'
end
Jeweler::RubygemsDotOrgTasks.new

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end


task :default => :test

require 'rdoc/task'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "gangsta #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
