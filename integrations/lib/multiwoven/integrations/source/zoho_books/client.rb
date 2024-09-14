# frozen_string_literal: true

require "stringio"

module Multiwoven
  module Integrations
    module Source
      module ZohoBooks
        include Multiwoven::Integrations::Core

        class Client < DestinationConnector
          prepend Multiwoven::Integrations::Core::RateLimiter

          def check_connection(connection_config)
            connection_config = connection_config.with_indifferent_access
            puts "connection_config zoho books: #{connection_config}"
            initialize_client(connection_config)
            authenticate_client
            success_status
          rescue StandardError => e
            handle_exception("ZOHO:BOOKS:DISCOVER:EXCEPTION:check_connection", "error", e)
            failure_status(e)
          end

          def discover(_connection_config = nil)
            catalog = build_catalog(load_catalog)
            catalog.to_multiwoven_message
          rescue StandardError => e
            handle_exception("ZOHO:BOOKS:DISCOVER:EXCEPTION:discover", "error", e)
          end

          def write(sync_config, records, action = "create")
            @action = sync_config.stream.action || action
            initialize_client(sync_config.destination.connection_specification)
            process_records(records, sync_config.stream)
          rescue StandardError => e
            handle_exception("ZOHO:BOOKS:WRITE:EXCEPTION:write", "error", e)
          end

          private

          def initialize_client(config)
            config = config.with_indifferent_access
            @client = ::ZohoBooks::Client.new(
              access_token: config[:access_token]
              # client_id: config[:client_id],
              # client_secret: config[:client_secret],
              # organization_id: config[:organization_id]
              # add Zoho Books specific configurations here
            )
          end

          def process_records(records, stream)
            write_success = 0
            write_failure = 0
            properties = stream.json_schema.with_indifferent_access[:properties]
            records.each do |record_object|
              record = extract_data(record_object, properties)
              send_data_to_zoho_books(stream.name, record)
              write_success += 1
            rescue StandardError => e
              handle_exception("ZOHO:BOOKS:WRITE:EXCEPTION:process_records", "error", e)
              write_failure += 1
            end
            tracking_message(write_success, write_failure)
          end

          def send_data_to_zoho_books(stream_name, record = {})
            args = build_args(@action, stream_name, record)
            zoho_books_stream = @client.send(stream_name) # Update with Zoho Books API structure
            zoho_books_data = { record_input: args }
            zoho_books_stream.send(@action, zoho_books_data) # Adjust to the correct API action
          end

          def build_args(action, stream_name, record)
            case action
            when :upsert
              [stream_name, record[:external_key], record]
            when :destroy
              [stream_name, record[:id]]
            else
              record
            end
          end

          def authenticate_client
            @client.get_invoices # Replace with a Zoho Books API method to test connection
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
