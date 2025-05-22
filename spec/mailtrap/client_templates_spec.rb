# frozen_string_literal: true

RSpec.describe Mailtrap::Client do
  subject(:client) { described_class.new(api_key:) }

  let(:api_key) { 'correct-api-key' }
  let(:account_id) { 123 }
  let(:template_id) { 456 }

  def stub_api(method, path, status:, body: nil)
    stub = stub_request(method, "https://mailtrap.io#{path}")
           .to_return(status:, body:)
    yield
    expect(stub).to have_been_requested
  end

  describe '#list_templates' do
    it 'returns templates list' do
      stub_api(:get, "/api/accounts/#{account_id}/email_templates", status: 200, body: '[{"id":1}]') do
        expect(client.list_templates(account_id:)).to eq([{ id: 1 }])
      end
    end
  end

  describe '#create_template' do
    let(:params) { { name: 'Test', subject: 'Subj', category: 'Promotion', body_html: '<div>body</div>' } }

    it 'sends POST request with JSON body' do
      stub = stub_request(:post, "https://mailtrap.io/api/accounts/#{account_id}/email_templates")
             .with(body: params.to_json)
             .to_return(status: 201, body: '{"id":2}')
      expect(client.create_template(account_id:, **params)).to eq({ id: 2 })
      expect(stub).to have_been_requested
    end
  end

  describe '#update_template' do
    it 'sends PATCH request with JSON body' do # rubocop:disable RSpec/ExampleLength
      stub = stub_request(:patch, "https://mailtrap.io/api/accounts/#{account_id}/email_templates/#{template_id}")
             .with(body: { name: 'Updated' }.to_json)
             .to_return(status: 200, body: '{"id":2,"name":"Updated"}')
      expect(
        client.update_template(account_id:, email_template_id: template_id, name: 'Updated')
      ).to eq({ id: 2, name: 'Updated' })
      expect(stub).to have_been_requested
    end
  end

  describe '#destroy_template' do
    it 'sends DELETE request' do
      stub_api(:delete, "/api/accounts/#{account_id}/email_templates/#{template_id}", status: 204) do
        expect(client.destroy_template(account_id:, email_template_id: template_id)).to be true
      end
    end
  end

  describe 'error handling' do
    it 'raises authorization error' do
      stub_api(:get, "/api/accounts/#{account_id}/email_templates", status: 401, body: '{"errors":["Unauthorized"]}') do
        expect { client.list_templates(account_id:) }.to raise_error(Mailtrap::AuthorizationError)
      end
    end
  end
end
