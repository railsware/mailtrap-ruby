# frozen_string_literal: true

require 'spec_helper'
require 'mailtrap/client'
require 'mailtrap/templates'

RSpec.describe Mailtrap::Templates do
  let(:client) { instance_double(Mailtrap::Client) }

  context 'non-strict mode' do
    let(:templates) { described_class.new(client) }

    describe '#list' do
      it 'returns templates list' do
        expect(client).to receive(:get).with(
          '/api/accounts/1/email_templates',
          params: { page: 1, per_page: 50 }
        ).and_return({
          data: [{ id: 1, name: 'List Template', uuid: 'abc', created_at: '2025-01-01T10:00:00Z', updated_at: '2025-01-02T10:00:00Z' }]
        })

        result = templates.list(account_id: 1)
        expect(result[:data]).to be_an(Array)
        expect(result[:data].first[:name]).to eq('List Template')
      end

      it 'returns empty array if no templates' do
        expect(client).to receive(:get).and_return({ data: [] })
        result = templates.list(account_id: 1)
        expect(result[:data]).to eq([])
      end
    end

    describe '#find' do
      it 'returns a full template object with all fields' do
        response = {
          id: 123,
          name: 'Template',
          subject: 'Subject',
          uuid: 'abc-uuid',
          created_at: '2021-01-01T00:00:00Z',
          updated_at: '2021-01-02T00:00:00Z'
        }

        expect(client).to receive(:get).with('/api/accounts/1/email_templates/123').and_return(response)

        result = templates.find(account_id: 1, template_id: 123)
        expect(result[:name]).to eq('Template')
        expect(result[:uuid]).to eq('abc-uuid')
      end
    end

    describe '#create' do
      it 'creates a template with valid fields' do
        body = {
          email_template: {
            name: 'Create Me',
            subject: 'Subject',
            category: 'Transactional',
            body_html: '<div>Hi</div>',
            body_text: 'Hi'
          }
        }

        expect(client).to receive(:post).with('/api/accounts/1/email_templates', body: body)
          .and_return({ id: 2, name: 'Create Me' })

        result = templates.create(account_id: 1, **body[:email_template])
        expect(result[:id]).to eq(2)
      end
    end

    describe '#patch' do
      it 'patches with compacted fields' do
        expect(client).to receive(:patch).with('/api/accounts/1/email_templates/2', body: {
          email_template: { subject: 'New subject' }
        }).and_return({ id: 2, updated: true })

        result = templates.patch(account_id: 1, template_id: 2, subject: 'New subject')
        expect(result[:updated]).to eq(true)
      end

      it 'omits nil values in patch' do
        expect(client).to receive(:patch).with(
          '/api/accounts/1/email_templates/2',
          body: { email_template: { subject: 'X' } } # no name key
        ).and_return({})
      
        templates.patch(account_id: 1, template_id: 2, subject: 'X', name: nil)
      end      
    end

    describe '#delete' do
      it 'calls delete endpoint' do
        expect(client).to receive(:delete).with('/api/accounts/1/email_templates/2')
          .and_return({ deleted: true })

        result = templates.delete(account_id: 1, template_id: 2)
        expect(result[:deleted]).to be true
      end
    end
  end

  context 'strict mode enabled' do
    let(:templates) { described_class.new(client, strict_mode: true) }

    describe 'input validation' do
      it 'raises on unknown key in create' do
        expect {
          templates.create(account_id: 1, name: 'Hi', subject: 'Yo', unknown: 'bad')
        }.to raise_error(ArgumentError, /Unexpected key in payload: unknown/)
      end

      it 'raises on unknown key in patch' do
        expect {
          templates.patch(account_id: 1, template_id: 2, foobar: 'nope')
        }.to raise_error(ArgumentError, /Unexpected key in payload: foobar/)
      end
    end

    describe 'output validation' do
      it 'raises if list item misses expected key' do
        expect(client).to receive(:get).with(anything, anything).and_return({
          data: [{ id: 1, name: 'X' }] # missing uuid, created_at, updated_at
        })

        expect {
          templates.list(account_id: 1)
        }.to raise_error(ArgumentError, /Missing key in template object: uuid/)
      end

      it 'raises if find result has unexpected field' do
        expect(client).to receive(:get).with(anything).and_return({
          id: 1,
          name: 'X',
          subject: 'Y',
          uuid: 'u',
          created_at: 'x',
          updated_at: 'y',
          extra: 'bad' # invalid
        })

        expect {
          templates.find(account_id: 1, template_id: 1)
        }.to raise_error(ArgumentError, /Unexpected key in response: extra/)        
      end
    end
  end
end