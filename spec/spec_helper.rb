$testing = true
SPEC = File.dirname(__FILE__)
$:.unshift File.expand_path("#{SPEC}/../lib")

require 'rack/lilypad'
require 'pp'

require 'rubygems'
require 'nokogiri'
require 'rack/test'
require 'sinatra/base'

require File.expand_path("#{SPEC}/fixtures/rails/config/environment")
require File.expand_path("#{SPEC}/fixtures/sinatra")

Spec::Runner.configure do |config|
end

# For use with rspec textmate bundle
def debug(object)
  puts "<pre>"
  puts object.pretty_inspect.gsub('<', '&lt;').gsub('>', '&gt;')
  puts "</pre>"
end

def validate_xml
  xsd = Nokogiri::XML::Schema(File.read(SPEC + '/fixtures/hoptoad_2_0.xsd'))
  doc = Nokogiri::XML(Rack::Lilypad::Hoptoad.last_request)
  
  errors = xsd.validate(doc)
  errors.each do |error|
    puts error.message
  end
  errors.length.should == 0
end

class TestError < RuntimeError
end
