# frozen_string_literal: true

RSpec.describe Multiwoven::Integrations::Source::ZohoBooks::Client do # rubocop:disable Metrics/BlockLength
  include WebMock::API

  before(:each) do
    WebMock.disable_net_connect!(allow_localhost: true)
  end

  # ! before this check whether the access_token is valid or not
  # ! connection here
  let(:client) { described_class.new }
  let(:connection_config) do
    {
      access_token: "access_token",
      client_id: "client_id",
      client_secret: "client_secret",
      organization_id: "organization_id"
    }
  end

  let(:zohobooks_invoices_json_schema) do
    catalog = client.discover.catalog
    catalog.streams.find { |stream| stream.name == "invoices" }.json_schema
  end

  let(:sync_config_json) do
    { source: {
        name: "DestinationConnectorName",
        type: "destination",
        connection_specification: {
          private_api_key: "test_api_key"
        }
      },
      destination: {
        name: "Zoho Books",
        type: "destination",
        connection_specification: connection_config
      },
      model: {
        name: "ExampleModel",
        query: "SELECT * FROM INVOICES LIMIT 1",
        query_type: "raw_sql",
        primary_key: "invoice_id"
      },
      stream: {
        name: "invoices",
        action: "create",
        request_rate_limit: 4,
        rate_limit_unit_seconds: 1,
        json_schema: zohobooks_invoices_json_schema
      },
      sync_mode: "full_refresh",
      cursor_field: "timestamp",
      destination_sync_mode: "insert" }.with_indifferent_access
  end

  let(:records) do
    [
      build_record("invoice_001"),
      build_record("invoice_002")
    ]
  end

  describe "#check_connection" do
    context "when the connection is successful" do
      before do
        stub_request(:post, "https://accounts.zoho.com/oauth/v2/token")
          .to_return(status: 200, body: "", headers: {})
      end

      it "returns a successful connection status" do
        allow(client).to receive(:authenticate_client).and_return(true)

        response = client.check_connection(connection_config)

        expect(response).to be_a(Multiwoven::Integrations::Protocol::MultiwovenMessage)
        expect(response.connection_status.status).to eq("succeeded")
      end
    end

    context "when the connection fails" do
      it "returns a failed connection status with an error message" do
        allow(client).to receive(:authenticate_client).and_raise(StandardError.new("connection failed"))

        response = client.check_connection(connection_config)

        expect(response).to be_a(Multiwoven::Integrations::Protocol::MultiwovenMessage)
        expect(response.connection_status.status).to eq("failed")
        expect(response.connection_status.message).to eq("connection failed")
      end
    end
  end

  describe "#discover" do
    it "returns a catalog" do
      message = client.discover
      catalog = message.catalog
      expect(catalog).to be_a(Multiwoven::Integrations::Protocol::Catalog)
      expect(catalog.request_rate_limit).to eql(600)
      expect(catalog.request_rate_limit_unit).to eql("minute")
      expect(catalog.request_rate_concurrency).to eql(10)

      invoice_stream = catalog.streams.first
      expect(invoice_stream.request_rate_limit).to eql(0)
      expect(invoice_stream.request_rate_limit_unit).to eql("minute")
      expect(invoice_stream.request_rate_concurrency).to eql(0)

      catalog.streams.each do |stream|
        expect(stream.supported_sync_modes).to eql(%w[incremental])
      end
    end
  end

  describe "#write" do
    context "when the write operation is successful" do
      before do
        stub_create_request("invoice_001", 200)
        stub_create_request("invoice_002", 200)
      end

      it "increments the success count" do
        response = client.write(sync_config, records)

        expect(response.tracking.success).to eq(records.size)
        expect(response.tracking.failed).to eq(0)
      end
    end

    context "when the write operation fails" do
      before do
        stub_create_request("invoice_001", 403)
        stub_create_request("invoice_002", 403)
      end

      it "increments the failure count" do
        response = client.write(sync_config, records)

        expect(response.tracking.failed).to eq(records.size)
        expect(response.tracking.success).to eq(0)
      end
    end
  end

  describe "#meta_data" do
    it "serves it github image url as icon" do
      image_url = "https://raw.githubusercontent.com/Multiwoven/multiwoven/main/integrations/lib/multiwoven/integrations/destination/zohobooks/icon.svg"
      expect(client.send(:meta_data)[:data][:icon]).to eq(image_url)
    end
  end

  private

  def build_record(invoice_id)
    {
      "properties": { "invoice_id": invoice_id }
    }
  end

  def stub_create_request(invoice_id, response_code)
    stub_request(:post, "https://books.zoho.com/api/v3/invoices")
      .with(
        body: "{\"properties\":{\"invoice_id\":\"#{invoice_id}\"}}",
        headers: {
          "Accept" => "application/json",
          "Authorization" => "Bearer access_token",
          "Content-Type" => "application/json",
          "Expect" => "",
          "User-Agent" => "zohobooks-api-client-ruby; 1.0.0"
        }
      )
      .to_return(status: response_code, body: "", headers: {})
  end

  def sync_config
    Multiwoven::Integrations::Protocol::SyncConfig.from_json(
      sync_config_json.to_json
    )
  end
end
