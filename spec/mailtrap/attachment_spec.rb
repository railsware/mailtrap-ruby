# frozen_string_literal: true

require 'stringio'

# rubocop:disable RSpec/MultipleMemoizedHelpers
RSpec.describe Mailtrap::Attachment do
  subject(:attachment) do
    described_class.new(
      content: content,
      filename: filename,
      type: type,
      disposition: disposition,
      content_id: content_id
    )
  end

  let(:filename) { 'attachment.txt' }
  let(:type) { nil }
  let(:disposition) { nil }
  let(:content_id) { nil }

  describe '#content' do
    subject(:attachment_content) { attachment.content }

    context 'when content is IO stream' do
      let(:content) { StringIO.new('hello world') }
      let(:base_64_encoded_content) { 'aGVsbG8gd29ybGQ=' }

      it 'encodes stream content' do
        expect(attachment_content).to eq(base_64_encoded_content)
      end
    end

    context 'when content is a base64 string' do
      let(:content) { 'dGV4dCBmaWxl' } # 'text file'

      it 'does not encode content' do
        expect(attachment_content).to eq('dGV4dCBmaWxl')
      end
    end

    context 'when content is non-base64 string' do
      let(:content) { 'non-base64' }

      it 'raises AttachmentContentError' do
        expect { attachment }.to raise_error(Mailtrap::AttachmentContentError)
      end
    end
  end

  describe '#as_json' do
    subject(:as_json) { attachment.as_json }

    let(:content) { 'dGV4dCBmaWxl' }

    it 'omits unset params' do
      expect(as_json).to eq('content' => 'dGV4dCBmaWxl', 'filename' => 'attachment.txt')
    end

    context 'when all params are set' do
      let(:type) { 'text/plain;charset=UTF-8' }
      let(:disposition) { 'attachment' }
      let(:content_id) { 'content id' }
      let(:expected_params) do
        {
          'content' => 'dGV4dCBmaWxl',
          'filename' => 'attachment.txt',
          'type' => 'text/plain;charset=UTF-8',
          'disposition' => 'attachment',
          'content_id' => 'content id'
        }
      end

      it 'shows all params' do
        expect(as_json).to eq(expected_params)
      end
    end
  end
end
# rubocop:enable RSpec/MultipleMemoizedHelpers
