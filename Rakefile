require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "flattr_rest"
    gem.summary = %Q{Flattr.com rest api client}
    gem.description = %Q{An OAuth wrapper to make it easier to consume the flattr rest api}
    gem.email = "joel.hansson@gmail.com"
    gem.homepage = "http://github.com/flattr/ruby-flattr-rest"
    gem.authors = ["Joel Hansson"]
    gem.add_development_dependency "rspec", ">= 1.2.9"
    gem.add_dependency "oauth"
    gem.add_dependency "nokogiri"
    gem.files =  FileList["[A-Z]*.*", "{bin,generators,lib,test,spec}/**/*"]
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

require 'spec/rake/spectask'
Spec::Rake::SpecTask.new(:spec) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.spec_files = FileList['spec/**/*_spec.rb']
end

Spec::Rake::SpecTask.new(:rcov) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rcov = true
end

task :spec => :check_dependencies

task :default => :spec

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "flattr_rest #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

task :clean do
  system "rm pkg/*"
end

task :reinstall do
  system "rake clean"
  system "rake build"
  system "/usr/bin/sudo gem install pkg/flattr_rest-0.0.1.gem"
end
