# frozen_string_literal: true

RSpec.describe Mailtrap::EmailTemplatesAPI, :vcr do
  subject(:template) { described_class.new(account_id, client) }

  let(:account_id) { ENV.fetch('MAILTRAP_ACCOUNT_ID', 1_111_111) }
  let(:client) { Mailtrap::Client.new(api_key: ENV.fetch('MAILTRAP_API_KEY', 'local-api-key')) }

  describe '#list', :vcr do
    subject(:list) { template.list }

    it 'maps response data to EmailTemplate objects' do
      expect(list).to all(be_a(Mailtrap::EmailTemplate))
      expect(list.first).to have_attributes(
        name: be_a(String),
        subject: be_a(String),
        category: be_a(String)
      )
    end

    context 'when api key is incorrect' do
      let(:client) { Mailtrap::Client.new(api_key: 'incorrect-api-key') }

      it 'raises authorization error' do
        expect { list }.to raise_error do |error|
          expect(error).to be_a(Mailtrap::AuthorizationError)
          expect(error.message).to include('Incorrect API token')
          expect(error.messages.any? { |msg| msg.include?('Incorrect API token') }).to be true
        end
      end
    end
  end

  describe '#get' do
    subject(:get) { template.get(template_id) }

    let!(:created_template) do
      template.create(
        name: 'Test Template',
        subject: 'Test Subject',
        category: 'Test Category',
        body_html: '<div>Test HTML</div>',
        body_text: 'Test Text'
      )
    end
    let(:template_id) { created_template.id }

    it 'maps response data to EmailTemplate object' do
      expect(get).to be_a(Mailtrap::EmailTemplate)
      expect(get).to have_attributes(
        id: template_id,
        name: 'Test Template',
        subject: 'Test Subject',
        category: 'Test Category'
      )
    end

    context 'when template does not exist' do
      let(:template_id) { 999_999 }

      it 'raises not found error' do
        expect { get }.to raise_error do |error|
          expect(error).to be_a(Mailtrap::Error)
          expect(error.message).to include('Not Found')
          expect(error.messages.any? { |msg| msg.include?('Not Found') }).to be true
        end
      end
    end
  end

  describe '#create' do
    subject(:create) { template.create(**request) }

    let(:request) do
      {
        name: 'New Template',
        subject: 'New Subject',
        category: 'New Category',
        body_html: '<div>New HTML</div>',
        body_text: 'New Text'
      }
    end

    it 'maps response data to EmailTemplate object' do
      expect(create).to be_a(Mailtrap::EmailTemplate)
      expect(create).to have_attributes(
        name: 'New Template',
        subject: 'New Subject',
        category: 'New Category'
      )
    end

    context 'with hash request' do
      let(:request) do
        {
          name: 'New Template',
          subject: 'New Subject',
          category: 'New Category',
          body_html: '<div>New HTML</div>',
          body_text: 'New Text'
        }
      end

      it 'maps response data to EmailTemplate object' do
        expect(create).to be_a(Mailtrap::EmailTemplate)
        expect(create).to have_attributes(
          name: 'New Template',
          subject: 'New Subject',
          category: 'New Category'
        )
      end
    end

    context 'when API returns an error' do
      let(:request) do
        {
          name: '', # Invalid value, but present
          subject: 'Invalid Subject',
          category: 'Invalid Category',
          body_html: '<div>Invalid</div>',
          body_text: 'Invalid'
        }
      end

      it 'raises a Mailtrap::Error' do
        expect { create }.to raise_error do |error|
          expect(error).to be_a(Mailtrap::Error)
          expect(error.message).to include('client error')
        end
      end
    end
  end

  describe '#update' do
    subject(:update) { template.update(template_id, **request) }

    let!(:created_template) do
      template.create(
        name: 'Original Template',
        subject: 'Original Subject',
        category: 'Original Category',
        body_html: '<div>Original HTML</div>',
        body_text: 'Original Text'
      )
    end
    let(:template_id) { created_template.id }
    let(:request) do
      {
        name: 'Updated Template',
        subject: 'Updated Subject',
        category: 'Updated Category',
        body_html: '<div>Updated HTML</div>',
        body_text: 'Updated Text'
      }
    end

    it 'maps response data to EmailTemplate object' do
      expect(update).to be_a(Mailtrap::EmailTemplate)
      expect(update).to have_attributes(
        name: 'Updated Template',
        subject: 'Updated Subject',
        category: 'Updated Category'
      )
    end

    context 'with hash request' do
      let(:request) do
        {
          name: 'Updated Template',
          subject: 'Updated Subject',
          category: 'Updated Category'
        }
      end

      it 'maps response data to EmailTemplate object' do
        expect(update).to be_a(Mailtrap::EmailTemplate)
        expect(update).to have_attributes(
          name: 'Updated Template',
          subject: 'Updated Subject',
          category: 'Updated Category'
        )
      end
    end

    context 'when updating only category' do
      let(:request) { { category: 'New Category Only' } }

      it 'updates only the category field' do
        expect(update).to be_a(Mailtrap::EmailTemplate)
        expect(update).to have_attributes(
          category: 'New Category Only'
        )
      end

      it 'preserves other fields unchanged' do
        expect(update).to have_attributes(
          name: 'Original Template',
          subject: 'Original Subject',
          body_html: '<div>Original HTML</div>',
          body_text: 'Original Text'
        )
      end
    end

    context 'when updating only body_html' do
      let(:request) { { body_html: '<div>New HTML Only</div>' } }

      it 'updates only the body_html field' do
        expect(update).to be_a(Mailtrap::EmailTemplate)
        expect(update).to have_attributes(
          body_html: '<div>New HTML Only</div>'
        )
      end

      it 'preserves other fields unchanged' do
        expect(update).to have_attributes(
          name: 'Original Template',
          subject: 'Original Subject',
          category: 'Original Category',
          body_text: 'Original Text'
        )
      end
    end

    context 'when updating multiple specific fields' do
      let(:request) do
        {
          category: 'Updated Category',
          body_html: '<div>Updated HTML</div>'
        }
      end

      it 'updates only the specified fields' do
        expect(update).to be_a(Mailtrap::EmailTemplate)
        expect(update).to have_attributes(
          category: 'Updated Category',
          body_html: '<div>Updated HTML</div>'
        )
      end

      it 'preserves other fields unchanged' do
        expect(update).to have_attributes(
          name: 'Original Template',
          subject: 'Original Subject',
          body_text: 'Original Text'
        )
      end
    end

    context 'when template does not exist' do
      let(:template_id) { 999_999 }

      it 'raises not found error' do
        expect { update }.to raise_error do |error|
          expect(error).to be_a(Mailtrap::Error)
          expect(error.message).to include('Not Found')
          expect(error.messages.any? { |msg| msg.include?('Not Found') }).to be true
        end
      end
    end
  end

  describe '#delete' do
    subject(:delete) { template.delete(template_id) }

    let!(:created_template) do
      template.create(
        name: 'Template to Delete',
        subject: 'Delete Subject',
        category: 'Delete Category',
        body_html: '<div>Delete HTML</div>',
        body_text: 'Delete Text'
      )
    end
    let(:template_id) { created_template.id }

    it 'returns no content' do
      expect(delete).to be_nil
    end

    context 'when template does not exist' do
      let(:template_id) { 999_999 }

      it 'raises not found error' do
        expect { delete }.to raise_error do |error|
          expect(error).to be_a(Mailtrap::Error)
          expect(error.message).to include('Not Found')
          expect(error.messages.any? { |msg| msg.include?('Not Found') }).to be true
        end
      end
    end
  end
end
