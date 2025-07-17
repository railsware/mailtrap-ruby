# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Mailtrap::Contact do
  subject(:contact) { described_class.new(attributes) }

  let(:attributes) do
    {
      id: '123',
      email: 'test@example.com',
      fields: { name: 'Test User' },
      list_ids: [1, 2],
      status: 'subscribed',
      created_at: 1_700_000_000,
      updated_at: 1_700_000_100,
      action:
    }
  end
  let(:action) { 'created' }

  describe '#newly_created?' do
    context "when action is 'created'" do
      let(:action) { 'created' }

      it { is_expected.to be_newly_created }
    end

    context "when action is 'updated'" do
      let(:action) { 'updated' }

      it { is_expected.not_to be_newly_created }
    end

    context 'when action is nil' do
      let(:action) { nil }

      it { is_expected.to be_newly_created }
    end
  end

  describe '#to_h' do
    it 'returns a hash of attributes except action and nils' do
      expect(contact.to_h).to eq({
                                   id: '123',
                                   email: 'test@example.com',
                                   fields: { name: 'Test User' },
                                   list_ids: [1, 2],
                                   status: 'subscribed',
                                   created_at: 1_700_000_000,
                                   updated_at: 1_700_000_100
                                 })
    end

    it 'omits nil values' do
      attributes[:fields] = nil
      expect(described_class.new(attributes).to_h).not_to have_key(:fields)
    end

    it 'returns without action' do
      expect(contact.to_h).not_to have_key(:action)
    end
  end
end
