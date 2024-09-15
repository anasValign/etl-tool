# frozen_string_literal: true

require 'net/http'
require 'uri'
require 'json'

module Api
  module V1
    class ConnectorsController < ApplicationController
      include Connectors
      before_action :set_connector, only: %i[show update destroy discover query_source]
      before_action :validate_query, only: %i[query_source]
      after_action :event_logger

      def index
        @connectors = current_workspace.connectors
        @connectors = @connectors.send(params[:type].downcase) if params[:type]
        @connectors = @connectors.page(params[:page] || 1)
        render json: @connectors, status: :ok
      end

      def show
        render json: @connector, status: :ok
      end

      def create
        result = CreateConnector.call(
          workspace: current_workspace,
          connector_params:
        )

        if result.success?
          @connector = result.connector
          render json: @connector, status: :created
        else
          render_error(
            message: "Connector creation failed",
            status: :unprocessable_entity,
            details: format_errors(result.connector)
          )
        end
      end

      def update
        result = UpdateConnector.call(
          connector: @connector,
          connector_params:
        )

        if result.success?
          @connector = result.connector
          render json: @connector, status: :ok
        else
          render_error(
            message: "Connector update failed",
            status: :unprocessable_entity,
            details: format_errors(result.connector)
          )
        end
      end

      def destroy
        @connector.destroy!
        head :no_content
      end

      def discover
        result = DiscoverConnector.call(
          connector: @connector
        )

        if result.success?
          @catalog = result.catalog
          render json: @catalog, status: :ok
        else
          render_error(
            message: "Discover catalog failed",
            status: :unprocessable_entity,
            details: format_errors(result.catalog)
          )
        end
      end

      def query_source
        puts "#{@connector.connector_name} #{@connector.configuration["data_center"]}"
        if @connector.source?
          
          if @connector.connector_name.match?(/^Zoho/i)

            access_token = crm_access_token(params[:query])

            result_crm = fetch_crm_data(access_token)
            
            puts "access -|  #{access_token}"
            puts "result -|  #{result_crm}"

            # Check if result_crm is an empty array
            if result_crm.empty?
              # Respond with an array containing an object with a message
              render json: [{ message: "No data available" }], status: :ok
            else
              # Render the actual data if it's not empty
              render json: result_crm, status: :ok
            end
          
          else
            result = QuerySource.call(
              connector: @connector,
              query: params[:query],
              limit: params[:limit] || 50
            )
  
            if result.success?
              @records = result.records.map(&:record).map(&:data)
              render json: @records, status: :ok
            else
              render_error(
                message: result["error"],
                status: :unprocessable_entity
              )
            end
          end

        else
          render_error(
            message: "Connector is not a source",
            status: :unprocessable_entity
          )
        end
      end

      private

      def crm_access_token(query)
        puts "Fetching access token with config: #{@connector.configuration} and query: #{query}"
  
        # Construct the URL for fetching the access token
        url = "https://accounts.zoho.com/oauth/v2/token?refresh_token=#{@connector.configuration['refresh_token']}&client_id=#{@connector.configuration['client_id']}&client_secret=#{@connector.configuration['client_secret']}&redirect_uri=http://www.zoho.com/books&grant_type=refresh_token"
        
        uri = URI(url)
        response = Net::HTTP.get_response(uri)
      
        if response.is_a?(Net::HTTPSuccess)
          # Parse the JSON response to extract the access token
          body = JSON.parse(response.body)
          access_token = body['access_token']
          
          puts "Access Token: #{access_token}"
          access_token
        else
          # Handle errors, such as invalid credentials or network issues
          handle_error(response)
          nil
        end
      end

      def fetch_crm_data(access_token)
        base_url = "https://www.zohoapis.com/books/v3/invoices?organization_id=#{@connector.configuration['organization_id']}"
        uri = URI(base_url)
        http = Net::HTTP.new(uri.host, uri.port)
        request = Net::HTTP::Get.new(uri.request_uri)
        request['Authorization'] = "Bearer #{access_token}"
        
        response = http.request(request)
        
        if response.is_a?(Net::HTTPSuccess)
          JSON.parse(response.body)
        else
          handle_error(response)
        end
      end

      def handle_error(response)
        # Handle the error from the API response
        puts "Error fetching invoices: #{response.body}"
        []
      end

      def set_connector
        @connector = current_workspace.connectors.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render_error(
          message: "Connector not found",
          status: :not_found
        )
      end

      def validate_query
        Utils::QueryValidator.validate_query(@connector.connector_query_type, params[:query])
      rescue StandardError => e
        render_error(
          message: "Query validation failed: #{e.message}",
          status: :unprocessable_entity
        )
      end

      def connector_params
        params.require(:connector).permit(:workspace_id,
                                          :connector_type,
                                          :connector_name, :name, :description, :query_type,
                                          configuration: {})
      end
    end
  end
end
