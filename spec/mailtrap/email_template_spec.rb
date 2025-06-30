# frozen_string_literal: true

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
