# frozen_string_literal: true

RSpec.shared_examples 'with attachments' do
  describe '#attachments=' do
    subject(:attachments_list) { mail.attachments }

    let(:attachments) { [{ content: StringIO.new('hello world'), filename: 'attachment.txt' }] }

    its(:size) { is_expected.to eq(1) }

    describe 'attachment_params' do
      subject(:attachment) { attachments_list.first }

      it { is_expected.to be_a(Mailtrap::Attachment) }
      its(:content) { is_expected.to eq('aGVsbG8gd29ybGQ=') }
      its(:filename) { is_expected.to eq('attachment.txt') }
    end
  end

  describe '#add_attachment' do
    subject(:add_attachment) { mail.add_attachment(**attachment) }

    let(:attachment) { { content: StringIO.new('hello world'), filename: 'attachment.txt' } }

    it 'adds an attachment' do
      expect { add_attachment }.to change { mail.attachments.size }.from(0).to(1)

      expect(mail.attachments.last.content).to eq('aGVsbG8gd29ybGQ=')
    end
  end
end
