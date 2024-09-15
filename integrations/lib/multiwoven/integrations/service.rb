# frozen_string_literal: true

module Multiwoven
  module Integrations
    class Service
      def initialize
        yield(self.class.config) if block_given?
      end
      class << self
        def connectors
          {
            source: build_connectors(
              ENABLED_SOURCES, "Source"
            ),
            destination: build_connectors(
              ENABLED_DESTINATIONS, "Destination"
            )
          }
        end

        def connector_class(connector_type, connector_name) 
          # *args
          Object.const_get(
            "Multiwoven::Integrations::#{connector_type}::#{connector_name}::Client"
          )

          # # Retrieve the class dynamically
          # klass = Object.const_get(
          #   "Multiwoven::Integrations::#{connector_type}::#{connector_name}::Client"
          # )

          # # Instantiate the class (assuming it's not a singleton)
          # client_instance = klass.new

          # # Only apply base_url if connector_name starts with "Zoho" or "zoho"
          # if connector_name.match?(/^Zoho/i)
          #   # Check for base_url in the args
          #   base_url = args.find { |arg| arg.is_a?(String) && arg.start_with?("http") }

          #   # If base_url is found, call the method to set it
          #   if base_url
          #     if client_instance.respond_to?(:setting_base_url)
          #       client_instance.setting_base_url(base_url)
          #     else
          #       raise NoMethodError, "Undefined method `setting_base_url` for #{client_instance.class}"
          #     end
          #   end
          # end

          # # Return the instance for further use
          # klass

        end

        def logger
          config.logger || default_logger
        end

        def config
          @config ||= Config.new
        end

        private

        def build_connectors(enabled_connectors, type)
          enabled_connectors.map do |connector|
            client = connector_class(type, connector).new
            client.meta_data[:data][:connector_spec] = client.connector_spec.to_h
            client.meta_data[:data]
          end
        end

        def default_logger
          @default_logger ||= Logger.new($stdout)
        end
      end
    end
  end
end
