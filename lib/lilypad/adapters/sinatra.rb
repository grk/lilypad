class Lilypad
  module Sinatra
    
    def self.included(base)
      base.set(:raise_errors, true) if Lilypad.should_notify?
    end
  end
end

if defined?(Sinatra::Base)
  Sinatra::Base.send(:include, Lilypad::Sinatra)
end

if defined?(Sinatra::Application)
  Sinatra::Application.send(:include, Lilypad::Sinatra)
end
