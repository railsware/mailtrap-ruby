# frozen_string_literal: true

# rubocop:disable RSpec/MultipleMemoizedHelpers
RSpec.describe Mailtrap::Sending::Mail do
  subject(:mail) do
    described_class.new(
      from: from,
      to: to,
      cc: cc,
      bcc: bcc,
      subject: mail_subject,
      text: text,
      html: html,
      attachments: attachments,
      headers: headers,
      category: category,
      custom_variables: custom_variables
    )
  end

  let(:from) { nil }
  let(:to) { [] }
  let(:cc) { [] }
  let(:bcc) { [] }
  let(:mail_subject) { nil }
  let(:text) { nil }
  let(:html) { nil }
  let(:attachments) { [] }
  let(:headers) { {} }
  let(:category) { nil }
  let(:custom_variables) { {} }

  describe '#as_json' do
    subject(:as_json) { mail.as_json }

    let(:from) { { email: 'test@example.com', name: 'Mailtrap User' } }
    let(:to) { [{ email: 'to@example.com' }, { email: 'to2@example.com', name: 'To Two' }] }
    let(:mail_subject) { 'This is subject' }
    let(:text) { 'This is text' }
    let(:expected_hash) do
      {
        'from' => { email: 'test@example.com', name: 'Mailtrap User' },
        'to' => [{ email: 'to@example.com' }, { email: 'to2@example.com', name: 'To Two' }],
        'cc' => [],
        'bcc' => [],
        'subject' => 'This is subject',
        'text' => 'This is text',
        'headers' => {},
        'attachments' => [],
        'custom_variables' => {}
      }
    end

    it 'omits unset values' do
      expect(as_json).to eq(expected_hash)
    end

    context 'when all values set' do
      let(:cc) { [{ email: 'cc@example.com' }] }
      let(:bcc) { [{ email: 'bcc@example.com' }] }
      let(:html) { '<div>Test HTML</div>' }
      let(:attachments) { [{ content: StringIO.new('hello world'), filename: 'attachment.txt' }] }
      let(:headers) { { 'Category-Header' => 'some_category' } }
      let(:category) { 'another_category' }
      let(:custom_variables) { { year: 2022 } }
      let(:expected_hash) do
        {
          'from' => { email: 'test@example.com', name: 'Mailtrap User' },
          'to' => [{ email: 'to@example.com' }, { email: 'to2@example.com', name: 'To Two' }],
          'cc' => [{ email: 'cc@example.com' }],
          'bcc' => [{ email: 'bcc@example.com' }],
          'subject' => 'This is subject',
          'text' => 'This is text',
          'html' => '<div>Test HTML</div>',
          'headers' => { 'Category-Header' => 'some_category' },
          'attachments' => [{ 'content' => 'aGVsbG8gd29ybGQ=', 'filename' => 'attachment.txt' }],
          'category' => 'another_category',
          'custom_variables' => { year: 2022 }
        }
      end

      it 'encodes attachment content' do
        expect(as_json).to eq(expected_hash)
      end
    end
  end

  describe '#to_json' do
    subject(:to_json) { mail.to_json }

    let(:from) { { email: 'test@example.com', name: 'Mailtrap User' } }
    let(:to) { [{ email: 'to@example.com' }, { email: 'to2@example.com', name: 'To Two' }] }
    let(:mail_subject) { 'This is subject' }
    let(:text) { 'This is text' }
    let(:cc) { [{ email: 'cc@example.com' }] }
    let(:bcc) { [{ email: 'bcc@example.com' }] }
    let(:html) { '<div>Test HTML</div>' }
    let(:attachments) { [{ content: StringIO.new('hello world'), filename: 'attachment.txt' }] }
    let(:headers) { { 'Category-Header' => 'some_category' } }
    let(:category) { 'another_category' }
    let(:expected_json) do
      '{' \
        '"to":[{"email":"to@example.com"},{"email":"to2@example.com","name":"To Two"}],' \
        '"from":{"email":"test@example.com","name":"Mailtrap User"},' \
        '"cc":[{"email":"cc@example.com"}],' \
        '"bcc":[{"email":"bcc@example.com"}],' \
        '"attachments":[{"content":"aGVsbG8gd29ybGQ=","filename":"attachment.txt"}],' \
        '"headers":{"Category-Header":"some_category"},' \
        '"custom_variables":{},' \
        '"subject":"This is subject",' \
        '"html":"<div>Test HTML</div>",' \
        '"text":"This is text",'\
        '"category":"another_category"' \
        '}'
    end

    it 'encodes as_json as string' do
      expect(to_json).to eq(expected_json)
    end
  end

  describe '#attachments=' do
    subject(:attachments_list) { mail.attachments }

    let(:attachments) { [{ content: StringIO.new('hello world'), filename: 'attachment.txt' }] }

    its(:size) { is_expected.to eq(1) }

    describe 'attachment_params' do
      subject(:attachment) { attachments_list.first }

      it { is_expected.to be_a(Mailtrap::Sending::Attachment) }
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
# rubocop:enable RSpec/MultipleMemoizedHelpers
