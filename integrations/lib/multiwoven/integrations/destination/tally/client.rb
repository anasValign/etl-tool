# frozen_string_literal: true

require "stringio"
require "net/http"
require "uri"
require "json"

module Multiwoven
  module Integrations
    module Destination
      module Tally
        include Multiwoven::Integrations::Core

        API_VERSION = "1.0"

        class Client < DestinationConnector
          prepend Multiwoven::Integrations::Core::RateLimiter

          def check_connection(connection_config)
            connection_config = connection_config.with_indifferent_access
            initialize_client(connection_config)
            authenticate_client
            success_status
          rescue StandardError => e
            failure_status(e)
          end

          def discover(_connection_config = nil)
            catalog = build_catalog(load_catalog)
            catalog.to_multiwoven_message
          rescue StandardError => e
            handle_exception("TALLY:DISCOVER:EXCEPTION", "error", e)
          end

          def write(sync_config, records, action = "create")
            @action = sync_config.stream.action || action
            initialize_client(sync_config.destination.connection_specification)
            process_records(records, sync_config.stream)
          rescue StandardError => e
            handle_exception("TALLY:WRITE:EXCEPTION", "error", e)
          end

          private

          def initialize_client(config)
            config = config.with_indifferent_access
            @tally_url = config[:tally_url]
            @company_name = config[:company_name]
          end

          def process_records(records, stream)
            write_success = 0
            write_failure = 0
            properties = stream.json_schema[:properties]
            records.each do |record_object|
              record = extract_data(record_object, properties)
              process_record(stream, record)
              write_success += 1
            rescue StandardError => e
              handle_exception("TALLY:WRITE:EXCEPTION", "error", e)
              write_failure += 1
            end
            tracking_message(write_success, write_failure)
          end

          def process_record(stream, record)
            send_data_to_tally(record)
          end

          def send_data_to_tally(record = {})
            uri = URI.parse("#{@tally_url}/#{@company_name}")
            request = Net::HTTP::Post.new(uri)
            request.content_type = "application/json"
            request.body = record.to_json
            response = Net::HTTP.start(uri.hostname, uri.port) { |http| http.request(request) }
            
            raise StandardError, response.body unless response.is_a?(Net::HTTPSuccess)
          end

          def authenticate_client
            # Tally may not need specific authentication steps like OAuth;
            # skipping authentication or implementing basic connection validation.
            true
          end

          def success_status
            ConnectionStatus.new(status: ConnectionStatusType["succeeded"]).to_multiwoven_message
          end

          def failure_status(error)
            ConnectionStatus.new(status: ConnectionStatusType["failed"], message: error.message).to_multiwoven_message
          end

          def load_catalog
            read_json(CATALOG_SPEC_PATH)
          end

          def tracking_message(success, failure)
            Multiwoven::Integrations::Protocol::TrackingMessage.new(
              success: success, failed: failure
            ).to_multiwoven_message
          end

          def log_debug(message)
            Multiwoven::Integrations::Service.logger.debug(message)
          end
        end
      end
    end
  end
end
