begin
  require 'rubygems'
  require 'oauth' #dependancy
  require 'nokogiri'
rescue LoadError
  puts "[flattr-rest] Unable to load dependencies"
  puts "[flattr-rest] flattr-rest depends on oauth and nokogiri"
  puts "[flattr-rest] $ sudo gem install oauth nokogiri"
  raise LoadError, "unable to load dependencies for flattr-rest"
end
require 'flattr_rest/flattr_rest'
require 'flattr_rest/exception'
require 'flattr_rest/amodel'
require 'flattr_rest/user'
require 'flattr_rest/thing'
