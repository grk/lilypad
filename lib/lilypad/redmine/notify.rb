class Lilypad
  class Redmine
    class Notify

      include Log::Methods

      def initialize(env, exception)
        @exception = exception
        @env = env

        env, request, session = parse

        api_key = {
          :project => Config.redmine_project,
          :tracker => Config.redmine_tracker,
          :api_key => Config.api_key
        }
        # optional settings
        api_key[:category] = Config.redmine_category if Config.redmine_category
        api_key[:assigned_to] = Config.redmine_assigned_to if Config.redmine_assigned_to
        api_key[:priority] = Config.redmine_priority if Config.redmine_priority

        message = {
          :notice => {
            :api_key => api_key.to_yaml,
            :error_message => "#{@exception.class.name}: #{@exception.message}",
            :error_class => @exception.class.name || {},
            :backtrace => @exception.backtrace,
            :environment => env.to_hash,
            :request => request,
            :session => session
          }
        }

        http_send message

        if env && success?
          env['redmine.notified'] = true
        end

        Config::Request.reset!
        log :notify, @response
        success?
      end

      private

      def filter(hash)
        return hash if Config.filters.empty?
        hash.inject({}) do |acc, (key, val)|
          match = Config.filters.any? { |f| key.to_s =~ Regexp.new(f) }
        acc[key] = match ? "[FILTERED]" : val
        acc
        end
      end

      def http_send(data)
        @uri = URI.parse Config.redmine_url
        Net::HTTP.start @uri.host, @uri.port do |http|
          headers = {
          'Content-type' => 'application/x-yaml',
          'Accept' => 'text/xml, application/xml'
          }

          http.read_timeout = 5 # seconds
          http.open_timeout = 2 # seconds
          @response = http.request_post(@uri.path, stringify_keys(data).to_yaml, headers)
        end
      end

      def parse
        env = filter ENV.to_hash.merge(@env || {})

        if @env
          request = Rack::Request.new @env
          params = request.params rescue Hash.new
          params = filter params
          request_path = request.script_name + request.path_info
          session = request.session
        else
          params = {}
          request_path = 'Internal'
          session = {}
        end

        [ env, request, session ]
      end

      def success?
        @response.class.superclass == Net::HTTPSuccess
      end

      def stringify_keys(hash) #:nodoc:
        hash.inject({}) do |h, pair|
          h[pair.first.to_s] = pair.last.is_a?(Hash) ? stringify_keys(pair.last) : pair.last
          h
        end
      end
    end
  end
end
