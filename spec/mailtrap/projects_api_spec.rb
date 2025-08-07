# frozen_string_literal: true

RSpec.describe Mailtrap::ProjectsAPI, :vcr do
  subject(:project) { described_class.new(account_id, client) }

  let(:account_id) { ENV.fetch('MAILTRAP_ACCOUNT_ID', 1_111_111) }
  let(:client) { Mailtrap::Client.new(api_key: ENV.fetch('MAILTRAP_API_KEY', 'local-api-key')) }

  describe '#list' do
    subject(:list) { project.list }

    it 'maps response data to Project objects' do
      expect(list).to all(be_a(Mailtrap::Project))
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
    subject(:get) { project.get(project_id) }

    let!(:created_project) do
      project.create(
        name: 'Test Project'
      )
    end
    let(:project_id) { created_project.id }

    it 'maps response data to Project object' do
      expect(get).to be_a(Mailtrap::Project)
      expect(get).to have_attributes(
        id: project_id,
        name: 'Test Project'
      )
    end

    context 'when project does not exist' do
      let(:project_id) { 999_999 }

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
    subject(:create) { project.create(**request) }

    let(:request) do
      {
        name: 'New Project'
      }
    end

    it 'maps response data to Project object' do
      expect(create).to be_a(Mailtrap::Project)
      expect(create).to have_attributes(
        name: 'New Project'
      )
    end

    context 'with hash request' do
      let(:request) do
        {
          name: 'New Project'
        }
      end

      it 'maps response data to Project object' do
        expect(create).to be_a(Mailtrap::Project)
        expect(create).to have_attributes(
          name: 'New Project'
        )
      end
    end

    context 'when API returns an error' do
      let(:request) do
        {
          name: '' # Invalid value, but present
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
    subject(:update) { project.update(project_id, **request) }

    let!(:created_project) do
      project.create(
        name: 'Original Project'
      )
    end
    let(:project_id) { created_project.id }
    let(:request) do
      {
        name: 'Updated Project'
      }
    end

    it 'maps response data to Project object' do
      expect(update).to be_a(Mailtrap::Project)
      expect(update).to have_attributes(
        name: 'Updated Project'
      )
    end

    context 'with hash request' do
      let(:request) do
        {
          name: 'Updated Project'
        }
      end

      it 'maps response data to Project object' do
        expect(update).to be_a(Mailtrap::Project)
        expect(update).to have_attributes(
          name: 'Updated Project'
        )
      end
    end

    context 'when updating only name' do
      let(:request) { { name: 'New Name Only' } }

      it 'updates only the name field' do
        expect(update).to be_a(Mailtrap::Project)
        expect(update).to have_attributes(
          name: 'New Name Only'
        )
      end
    end

    context 'when project does not exist' do
      let(:project_id) { 999_999 }

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
    subject(:delete) { project.delete(project_id) }

    let!(:created_project) do
      project.create(
        name: 'Project to Delete'
      )
    end
    let(:project_id) { created_project.id }

    it 'returns no content' do
      expect(delete).to be_nil
    end

    context 'when project does not exist' do
      let(:project_id) { 999_999 }

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
