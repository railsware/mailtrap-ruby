# frozen_string_literal: true

RSpec.describe Mailtrap::Template do
  subject(:template) { described_class.new(account_id, client) }

  let(:account_id) { 1_111_111 }
  let(:client) { Mailtrap::Client.new(api_key: 'correct-api-key') }

  describe '#list', :vcr do
    subject(:list) { template.list }

    it 'returns an array of EmailTemplate objects' do
      expect(list).to all(be_a(Mailtrap::EmailTemplate))
    end

    it 'maps response data to EmailTemplate objects' do
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

  describe '#get', :vcr do
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

    it 'returns an EmailTemplate object' do
      expect(get).to be_a(Mailtrap::EmailTemplate)
    end

    it 'maps response data to EmailTemplate object' do
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

  describe '#create', :vcr do
    subject(:create) { template.create(request) }

    let(:request) do
      Mailtrap::EmailTemplateRequest.new(
        name: 'New Template',
        subject: 'New Subject',
        category: 'New Category',
        body_html: '<div>New HTML</div>',
        body_text: 'New Text'
      )
    end

    it 'returns an EmailTemplate object' do
      expect(create).to be_a(Mailtrap::EmailTemplate)
    end

    it 'maps response data to EmailTemplate object' do
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

      it 'returns an EmailTemplate object' do
        expect(create).to be_a(Mailtrap::EmailTemplate)
      end

      it 'maps response data to EmailTemplate object' do
        expect(create).to have_attributes(
          name: 'New Template',
          subject: 'New Subject',
          category: 'New Category'
        )
      end
    end

    context 'with invalid request' do
      let(:request) do
        Mailtrap::EmailTemplateRequest.new(
          name: 'New Template',
          subject: 'New Subject'
          # category is missing
        )
      end

      it 'raises validation error' do
        expect { create }.to raise_error(ArgumentError, 'Missing required fields: category')
      end
    end
  end

  describe '#update', :vcr do
    subject(:update) { template.update(template_id, request) }

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
      Mailtrap::EmailTemplateRequest.new(
        name: 'Updated Template',
        subject: 'Updated Subject',
        category: 'Updated Category'
      )
    end

    it 'returns an EmailTemplate object' do
      expect(update).to be_a(Mailtrap::EmailTemplate)
    end

    it 'maps response data to EmailTemplate object' do
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

      it 'returns an EmailTemplate object' do
        expect(update).to be_a(Mailtrap::EmailTemplate)
      end

      it 'maps response data to EmailTemplate object' do
        expect(update).to have_attributes(
          name: 'Updated Template',
          subject: 'Updated Subject',
          category: 'Updated Category'
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

  describe '#delete', :vcr do
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

    it 'returns true' do
      expect(delete).to be true
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

RSpec.describe Mailtrap::EmailTemplateRequest do
  describe '#initialize' do
    subject(:request) { described_class.new(attributes) }

    context 'with valid attributes' do
      let(:attributes) do
        {
          name: 'My Template',
          subject: 'My Subject',
          category: 'My Category',
          body_html: '<div>HTML</div>',
          body_text: 'Text'
        }
      end

      it 'creates a valid request' do
        expect(request).to have_attributes(
          name: 'My Template',
          subject: 'My Subject',
          category: 'My Category',
          body_html: '<div>HTML</div>',
          body_text: 'Text'
        )
      end
    end

    context 'with missing required fields' do
      let(:attributes) do
        {
          name: 'My Template',
          subject: 'My Subject'
          # category is missing
        }
      end

      it 'raises an ArgumentError' do
        expect { request }.to raise_error(ArgumentError, 'Missing required fields: category')
      end
    end

    context 'with fields exceeding maximum length' do
      let(:attributes) do
        {
          name: 'x' * 256, # exceeds MAX_LENGTH
          subject: 'My Subject',
          category: 'My Category'
        }
      end

      it 'raises an ArgumentError' do
        expect { request }.to raise_error(ArgumentError, 'name exceeds maximum length of 255 characters')
      end
    end

    context 'with body fields exceeding maximum length' do
      let(:attributes) do
        {
          name: 'My Template',
          subject: 'My Subject',
          category: 'My Category',
          body_html: 'x' * (Mailtrap::Template::MAX_BODY_LENGTH + 1)
        }
      end

      it 'raises an ArgumentError' do
        expect { request }.to raise_error(ArgumentError, 'body_html exceeds maximum length of 10000000 characters')
      end
    end
  end

  describe '#to_h' do
    subject(:hash) { request.to_h }

    let(:request) do
      described_class.new(
        name: 'My Template',
        subject: 'My Subject',
        category: 'My Category',
        body_html: '<div>HTML</div>',
        body_text: 'Text'
      )
    end

    it 'returns a hash with all attributes' do
      expect(hash).to eq(
        name: 'My Template',
        subject: 'My Subject',
        category: 'My Category',
        body_html: '<div>HTML</div>',
        body_text: 'Text'
      )
    end

    context 'with nil optional fields' do
      let(:request) do
        described_class.new(
          name: 'My Template',
          subject: 'My Subject',
          category: 'My Category'
        )
      end

      it 'excludes nil fields from the hash' do
        expect(hash).to eq(
          name: 'My Template',
          subject: 'My Subject',
          category: 'My Category'
        )
      end
    end
  end
end

RSpec.describe Mailtrap::EmailTemplate do
  describe '#initialize' do
    subject(:template) { described_class.new(attributes) }

    let(:attributes) do
      {
        id: 26_730,
        uuid: '018dd5e3-f6d2-7c00-8f9b-e5c3f2d8a132',
        name: 'My Template',
        subject: 'My Subject',
        category: 'My Category',
        body_html: '<div>HTML</div>',
        body_text: 'Text',
        created_at: '2021-01-01T00:00:00Z',
        updated_at: '2021-01-01T00:00:00Z'
      }
    end

    it 'creates a template with all attributes' do
      expect(template).to have_attributes(
        id: 26_730,
        uuid: '018dd5e3-f6d2-7c00-8f9b-e5c3f2d8a132',
        name: 'My Template',
        subject: 'My Subject',
        category: 'My Category',
        body_html: '<div>HTML</div>',
        body_text: 'Text',
        created_at: '2021-01-01T00:00:00Z',
        updated_at: '2021-01-01T00:00:00Z'
      )
    end
  end

  describe '#to_h' do
    subject(:hash) { template.to_h }

    let(:template) do
      described_class.new(
        id: 26_730,
        uuid: '018dd5e3-f6d2-7c00-8f9b-e5c3f2d8a132',
        name: 'My Template',
        subject: 'My Subject',
        category: 'My Category',
        body_html: '<div>HTML</div>',
        body_text: 'Text',
        created_at: '2021-01-01T00:00:00Z',
        updated_at: '2021-01-01T00:00:00Z'
      )
    end

    it 'returns a hash with all attributes' do
      expect(hash).to eq(
        id: 26_730,
        uuid: '018dd5e3-f6d2-7c00-8f9b-e5c3f2d8a132',
        name: 'My Template',
        subject: 'My Subject',
        category: 'My Category',
        body_html: '<div>HTML</div>',
        body_text: 'Text',
        created_at: '2021-01-01T00:00:00Z',
        updated_at: '2021-01-01T00:00:00Z'
      )
    end
  end
end
