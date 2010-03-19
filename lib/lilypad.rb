require File.expand_path("#{File.dirname(__FILE__)}/../require")
Require.lib! unless defined?(::Lilypad)

class Lilypad
  class <<self
    
    def active?
      Config.api_key
    end
    
    def config(api_key=nil, &block)
      if api_key
        Config.api_key api_key
      end
      if block_given?
        Config.class_eval &block
      end
    end
    
    def deploy(options)
      if active? && should_notify?
        Hoptoad::Deploy.new options
      end
    end
    
    def notify(exception, env=nil)
      if active? && should_notify?
        if Config.redmine_url
          Redmine::Notify.new env, exception
        else # send to Hoptoad
          Hoptoad::Notify.new env, exception
        end
      end
    end
    
    def should_notify?
      Config.always_notify || Config.environments.include?(ENV['RACK_ENV'])
    end
  end
end

def Lilypad(api_key=nil, &block)
  Lilypad.config api_key, &block
end
