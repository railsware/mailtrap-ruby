# frozen_string_literal: true

RSpec.describe Mailtrap::ContactsImportRequest do
  subject(:request) { described_class.new }

  # Test data
  let(:test_email) { 'john.doe@example.com' }
  let(:another_email) { 'jane.smith@example.com' }
  let(:test_fields) { { first_name: 'John', last_name: 'Doe' } }
  let(:additional_fields) { { age: 30, company: 'Example Corp' } }
  let(:test_list_ids) { [1, 2, 3] }

  # Shared examples for method chaining
  shared_examples 'supports method chaining' do |method_name, **args|
    it 'returns self for method chaining' do
      result = request.public_send(method_name, **args)
      expect(result).to eq(request)
    end
  end

  # Shared examples for contact creation
  shared_examples 'creates contact when not exists' do |method_name, expected_data, **method_args|
    it "creates a new contact using #{method_name}" do
      result = request.public_send(method_name, **method_args)

      expect(result).to eq(request)
      expect(request.as_json).to contain_exactly(expected_data)
    end
  end

  describe '#upsert' do
    include_examples 'supports method chaining', :upsert, email: 'test@example.com', fields: { name: 'Test' }

    context 'when contact does not exist' do
      include_examples 'creates contact when not exists', :upsert, {
        email: 'john.doe@example.com',
        fields: { first_name: 'John', last_name: 'Doe' },
        list_ids_included: [],
        list_ids_excluded: []
      }, email: 'john.doe@example.com', fields: { first_name: 'John', last_name: 'Doe' }

      it 'creates a contact with empty fields when none provided' do
        result = request.upsert(email: test_email)

        expect(result).to eq(request)
        expect(request.as_json).to contain_exactly(
          email: test_email,
          fields: {},
          list_ids_included: [],
          list_ids_excluded: []
        )
      end
    end

    context 'when contact already exists' do
      before { request.upsert(email: test_email, fields: { first_name: 'John' }) }

      it 'merges new fields with existing fields' do
        result = request.upsert(email: test_email, fields: additional_fields)

        expect(result).to eq(request)
        expect(request.as_json).to contain_exactly(
          email: test_email,
          fields: { first_name: 'John', **additional_fields },
          list_ids_included: [],
          list_ids_excluded: []
        )
      end

      it 'overwrites existing field values' do
        result = request.upsert(email: test_email, fields: { first_name: 'Jane' })

        expect(result).to eq(request)
        expect(request.as_json).to contain_exactly(
          email: test_email,
          fields: { first_name: 'Jane' },
          list_ids_included: [],
          list_ids_excluded: []
        )
      end

      it 'preserves existing list associations when upserting fields' do
        request.add_to_lists(email: test_email, list_ids: [1, 2])
        request.remove_from_lists(email: test_email, list_ids: [3])

        request.upsert(email: test_email, fields: { last_name: 'Doe' })

        expect(request.as_json).to contain_exactly(
          email: test_email,
          fields: { first_name: 'John', last_name: 'Doe' },
          list_ids_included: [1, 2],
          list_ids_excluded: [3]
        )
      end
    end
  end

  describe '#add_to_lists' do
    include_examples 'supports method chaining', :add_to_lists, email: 'test@example.com', list_ids: [1, 2]

    context 'when contact does not exist' do
      include_examples 'creates contact when not exists', :add_to_lists, {
        email: 'jane.doe@example.com',
        fields: {},
        list_ids_included: [1, 2, 3],
        list_ids_excluded: []
      }, email: 'jane.doe@example.com', list_ids: [1, 2, 3]
    end

    context 'when contact already exists' do
      before { request.upsert(email: another_email, fields: { name: 'Jane' }) }

      it 'adds new list IDs to existing inclusions' do
        request.add_to_lists(email: another_email, list_ids: [1, 2])
        result = request.add_to_lists(email: another_email, list_ids: [3, 4])

        expect(result).to eq(request)
        expect(request.as_json).to contain_exactly(
          email: another_email,
          fields: { name: 'Jane' },
          list_ids_included: [1, 2, 3, 4],
          list_ids_excluded: []
        )
      end

      it 'prevents duplicate list IDs in inclusions' do
        request.add_to_lists(email: another_email, list_ids: [1, 2])
        result = request.add_to_lists(email: another_email, list_ids: [2, 3])

        expect(result).to eq(request)
        expect(request.as_json).to contain_exactly(
          email: another_email,
          fields: { name: 'Jane' },
          list_ids_included: [1, 2, 3],
          list_ids_excluded: []
        )
      end
    end

    it 'works with method chaining on same email' do
      request
        .add_to_lists(email: test_email, list_ids: [1, 2])
        .add_to_lists(email: test_email, list_ids: [3, 4])

      expect(request.as_json.first[:list_ids_included]).to eq([1, 2, 3, 4])
    end
  end

  describe '#remove_from_lists' do
    include_examples 'supports method chaining', :remove_from_lists, email: 'test@example.com', list_ids: [5, 6]

    context 'when contact does not exist' do
      include_examples 'creates contact when not exists', :remove_from_lists, {
        email: 'bob.smith@example.com',
        fields: {},
        list_ids_included: [],
        list_ids_excluded: [5, 6, 7]
      }, email: 'bob.smith@example.com', list_ids: [5, 6, 7]
    end

    context 'when contact already exists' do # rubocop:disable RSpec/MultipleMemoizedHelpers
      let(:bob_email) { 'bob.smith@example.com' }

      before { request.upsert(email: bob_email, fields: { name: 'Bob' }) }

      it 'adds new list IDs to existing exclusions' do
        request.remove_from_lists(email: bob_email, list_ids: [5, 6])
        result = request.remove_from_lists(email: bob_email, list_ids: [7, 8])

        expect(result).to eq(request)
        expect(request.as_json).to contain_exactly(
          email: bob_email,
          fields: { name: 'Bob' },
          list_ids_included: [],
          list_ids_excluded: [5, 6, 7, 8]
        )
      end

      it 'prevents duplicate list IDs in exclusions' do
        request.remove_from_lists(email: bob_email, list_ids: [5, 6])
        result = request.remove_from_lists(email: bob_email, list_ids: [6, 7])

        expect(result).to eq(request)
        expect(request.as_json).to contain_exactly(
          email: bob_email,
          fields: { name: 'Bob' },
          list_ids_included: [],
          list_ids_excluded: [5, 6, 7]
        )
      end
    end

    it 'works with method chaining on same email' do
      request
        .remove_from_lists(email: test_email, list_ids: [5, 6])
        .remove_from_lists(email: test_email, list_ids: [7, 8])

      expect(request.as_json.first[:list_ids_excluded]).to eq([5, 6, 7, 8])
    end
  end

  describe 'serialization methods' do
    describe '#as_json' do
      context 'when no contacts added' do
        it 'returns an empty array' do
          expect(request.as_json).to eq([])
        end
      end

      context 'when contacts are added' do
        before do
          request
            .upsert(email: test_email, fields: { name: 'John' })
            .add_to_lists(email: test_email, list_ids: [1])
            .upsert(email: another_email, fields: { name: 'Jane' })
            .remove_from_lists(email: another_email, list_ids: [2])
        end

        it 'returns array of contact data hashes' do
          result = request.as_json

          expect(result).to contain_exactly(
            {
              email: test_email,
              fields: { name: 'John' },
              list_ids_included: [1],
              list_ids_excluded: []
            },
            {
              email: another_email,
              fields: { name: 'Jane' },
              list_ids_included: [],
              list_ids_excluded: [2]
            }
          )
        end
      end
    end

    describe '#to_a' do
      it 'is an alias for #as_json' do
        request.upsert(email: 'test@example.com', fields: { name: 'Test' })

        expect(request.to_a).to eq(request.as_json)
      end
    end
  end
end
