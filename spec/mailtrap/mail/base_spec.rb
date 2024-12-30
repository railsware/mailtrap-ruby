# frozen_string_literal: true

require_relative 'shared'

# rubocop:disable RSpec/MultipleMemoizedHelpers
RSpec.describe Mailtrap::Mail::Base do
  subject(:mail) do
    described_class.new(
      from: from,
      to: to,
      reply_to: reply_to,
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
  let(:reply_to) { nil }
  let(:cc) { [] }
  let(:bcc) { [] }
  let(:mail_subject) { nil }
  let(:text) { nil }
  let(:html) { nil }
  let(:attachments) { [] }
  let(:headers) { {} }
  let(:category) { nil }
  let(:custom_variables) { {} }

  it_behaves_like 'with attachments'

  specify do
    mail.subject = 'Hello World'
    expect(mail.subject).to eq('Hello World')
  end

  specify do
    mail.text = "LINE1\nLINE2"
    expect(mail.text).to eq("LINE1\nLINE2")
  end

  specify do
    mail.html = '<h2>Hello World</h2>'
    expect(mail.html).to eq('<h2>Hello World</h2>')
  end

  specify do
    mail.category = 'My Category'
    expect(mail.category).to eq('My Category')
  end

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
      let(:reply_to) { { email: 'reply-to@railsware.com' } }
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
          'reply_to' => { email: 'reply-to@railsware.com' },
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
    let(:reply_to) { { email: 'reply-to@railsware.com', name: 'Reply To' } }
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
        '"from":{"email":"test@example.com","name":"Mailtrap User"},' \
        '"to":[{"email":"to@example.com"},{"email":"to2@example.com","name":"To Two"}],' \
        '"reply_to":{"email":"reply-to@railsware.com","name":"Reply To"},' \
        '"cc":[{"email":"cc@example.com"}],' \
        '"bcc":[{"email":"bcc@example.com"}],' \
        '"subject":"This is subject",' \
        '"text":"This is text",' \
        '"html":"<div>Test HTML</div>",' \
        '"attachments":[{"content":"aGVsbG8gd29ybGQ=","filename":"attachment.txt"}],' \
        '"headers":{"Category-Header":"some_category"},' \
        '"custom_variables":{},' \
        '"category":"another_category"' \
        '}'
    end

    it 'encodes as_json as string' do
      expect(to_json).to eq(expected_json)
    end
  end
end
# rubocop:enable RSpec/MultipleMemoizedHelpers
