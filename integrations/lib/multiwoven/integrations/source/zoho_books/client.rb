# frozen_string_literal: true

# require "zoho_books" # or the correct gem for Zoho Books
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
            create_connection(connection_config)
            # authenticate_client
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
            create_connection(sync_config.destination.connection_specification)
            process_records(records, sync_config.stream)
          rescue StandardError => e
            handle_exception("ZOHO:BOOKS:WRITE:EXCEPTION:write", "error", e)
          end

          # def setting_base_url(url)
          #   @base_url = url
          #   puts "setting_base_url only for zoho: #{@base_url}"
          # end

          private

          def create_connection(config)
            # config = config.with_indifferent_access
            @client_id = config[:client_id]
            @client_secret = config[:client_secret]
            @refresh_token = config[:refresh_token]
            @organization_id = config[:organization_id]
            @data_center = config[:data_center]
            @base_url = config[:base_url]

            # Zoho token endpoint
            token_url = "https://accounts.zoho.com/oauth/v2/token"
              
            # Prepare the request parameters
            uri = URI.parse(token_url)
            params = {
              client_id: @client_id,
              client_secret: @client_secret,
              refresh_token: @refresh_token,
              grant_type: 'refresh_token'
            }
            
            # Make the HTTP POST request to get the access token
            response = Net::HTTP.post_form(uri, params)
          
            # Parse the response
            result = JSON.parse(response.body)
          
            # Check if the response has an error or return the access token
            if result["access_token"]
              @access_token = result["access_token"]
              puts "@access_token = result[VITORY]: #{@access_token}"
              @access_token
            else
              raise "Error fetching access token: #{result['error']}"
            end
          end

          def query(connection, query)
            connection.exec(query) do |result|
              result.map do |row|
                RecordMessage.new(data: row, emitted_at: Time.now.to_i).to_multiwoven_message
              end
            end
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

          # def authenticate_client
          #   @client.get_invoices # Replace with a Zoho Books API method to test connection
          # end

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
