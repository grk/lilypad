class Lilypad
  class Config
    class <<self
      
      def api_key(api_key=nil, &block)
        @api_key = api_key unless api_key.nil?
        @api_key_block = block if block_given?
        @api_key || @api_key_block
      end
      
      def deploy_url(url=nil)
        @deploy_url = url unless url.nil?
        @deploy_url || "http://hoptoadapp.com:80/deploys.txt"
      end
      
      def environments(environments=nil)
        @environments = environments unless environments.nil?
        @environments || %w(production staging)
      end
      
      def filters(filters=nil)
        @filters = filters unless filters.nil?
        @filters || []
      end
      
      def log(log=nil)
        @log = log unless log.nil?
        @log
      end
      
      def notify_url(url=nil)
        @notify_url = url unless url.nil?
        @notify_url || "http://hoptoadapp.com:80/notifier_api/v2/notices"
      end
      
      def rails
        require "#{File.dirname(__FILE__)}/adapters/rails"
      end
      
      def sinatra
        require "#{File.dirname(__FILE__)}/adapters/sinatra"
      end

      def always_notify(always_notify=true)
        @always_notify = always_notify
      end
      
      def redmine_url(url=nil)
        @redmine_url = url unless url.nil?
        @redmine_url
      end

      def redmine_project(project=nil)
        @redmine_project = project unless project.nil?
        @redmine_project
      end

      def redmine_tracker(tracker=nil)
        @redmine_tracker = tracker unless tracker.nil?
        @redmine_tracker
      end

      def redmine_category(category=nil)
        @redmine_category = category unless category.nil?
        @redmine_category
      end

      def redmine_assigned_to(assigned_to=nil)
        @redmine_assigned_to = assigned_to unless assigned_to.nil?
        @redmine_assigned_to
      end

      def redmine_priority(priority=nil)
        @redmine_priority = priority.to_i unless priority.nil?
        @redmine_priority
      end
    end
    
    module Methods
      
      def api_key(env=nil, exception=nil)
        if Config.api_key.respond_to?(:call)
          Config.api_key.call env, exception
        else
          Config.api_key
        end
      end
    end
  end
end