# frozen_string_literal: true

# from: https://github.com/rails/rails/blob/3235827585d87661942c91bc81f64f56d710f0b2/railties/lib/rails/rack/logger.rb

require "active_support/core_ext/time/conversions"
require "active_support/log_subscriber"
require "rack/body_proxy"

module Rails
  module Rack
    # Sets log tags, logs the request, calls the app, and flushes the logs.
    #
    # Log tags (+taggers+) can be an Array containing: methods that the +request+
    # object responds to, objects that respond to +to_s+ or Proc objects that accept
    # an instance of the +request+ object.
    class LoggerWithHost < Logger
      private
        # Started GET "/session/new" for 127.0.0.1 at 2012-09-26 14:51:42 -0700
        def started_request_message(request) # :doc:
          sprintf('[%s] Started %s "%s" for %s at %s',
            request.host,
            request.raw_request_method,
            request.filtered_path,
            request.remote_ip,
            Time.now)
        end
    end
  end
end
