# frozen_string_literal: true

RSpec.describe Mailtrap::Mail do
  describe '.from_message' do
    subject(:mail) do
      # This method is called by ActionMailer before passing the message to delivery,
      # and populates some redundant headers on the message.
      # We want to ensure they are removed.
      message.encoded
      described_class.from_message(message)
    end

    let(:message) { Mail::Message.new(**message_params) }
    let(:message_params) do
      {
        from: 'Mailtrap Test <mailtrap@mailtrap.io>',
        to: 'To 1 <to_1@railsware.com>, to_2@railsware.com',
        cc: 'cc_1@railsware.com, Cc 2 <cc_2@railsware.com>',
        bcc: 'bcc_1@railsware.com, bcc_2@railsware.com',
        subject: 'You are awesome!',
        body: 'Text body',
        category: 'Module Test'
      }
    end

    its(:from) { is_expected.to eq({ name: 'Mailtrap Test', email: 'mailtrap@mailtrap.io' }) }
    its(:to) { is_expected.to eq([{ name: 'To 1', email: 'to_1@railsware.com' }, { email: 'to_2@railsware.com' }]) }
    its(:cc) { is_expected.to eq([{ email: 'cc_1@railsware.com' }, { name: 'Cc 2', email: 'cc_2@railsware.com' }]) }
    its(:bcc) { is_expected.to eq([{ email: 'bcc_1@railsware.com' }, { email: 'bcc_2@railsware.com' }]) }
    its(:subject) { is_expected.to eq('You are awesome!') }
    its(:text) { is_expected.to eq('Text body') }
    its(:category) { is_expected.to eq('Module Test') }

    describe '#headers' do
      subject(:headers) { mail.headers }

      it { is_expected.to be_empty }

      context 'when custom headers added' do
        let(:expected_headers) do
          {
            'X-Special-Domain-Specific-Header' => 'SecretValue',
            'Reply-To' => 'Reply To <reply-to@railsware.com>',
            'One-more-custom-header' => 'CustomValue'
          }
        end

        before do
          message.reply_to = 'Reply To <reply-to@railsware.com>'
          message.headers('X-Special-Domain-Specific-Header': 'SecretValue')
          message.headers('One-more-custom-header': 'CustomValue')
        end

        it { is_expected.to eq(expected_headers) }
      end
    end

    describe '#attachment' do
      subject(:json_attachments) { mail.attachments.map(&:as_json) }

      let(:expected_json_attachment) do
        [
          {
            'content' => 'VGhpcyBpcyBhIHRleHQgZmlsZQo=',
            'disposition' => 'attachment',
            'filename' => 'file.txt',
            'content_id' => a_string_ending_with('@test.mail'),
            'type' => 'text/plain'
          },
          {
            'content' => 'iVBORw0KGgoAAAANSUhEUgAAABgAAAAYCAYAAADgdz34AAAABmJLR0QA/wD/AP+gvaeTAAABiElEQVRIid3VSW5UMRCA4U8d0gIx7AjhAghBTgFICAkxRFHukDDDIRiuwI7xPNAMISQRV4CABFmkWbie2nrt9muaFZTkxavhr7Jfucz/Ln2s4hU28B0/sBO6VczPCl/GNoYd6wsuZ3ELWKuBe3iSAQa4g7M4jEM4jRt4g5+4lMEHEbc+KUED/xVOvY5iThXgg/gek+UMfq4CbstU8L7RmU/c3qxwUkc0TnN/CT9Ycn4djrenhB/H24j5iMXQX8TTUsCncD6T6daUtzyp8hNSV30uJfgWAUfje70AqMFF7FC6kGOy20rQPoKTBd1ii3EsbF9LCUpH1K62q1uWwr5RSvAyjHdb+rzqSZU38iB8npWMTZu+M96mzU5qfT6H98FYKTn0sRUONwv2hQqcNK+G2FSZsNeNRsX5CqwtF7CHfVzpcn6cJbmlfqsPSJXvRczDaarpZUmaf3JP6pAjsZZw3+jM9/FIffKOyTXpRnY9OJu4+ifgXOaljnghtedurA94HraZn8x/Q34DYaON8Fk9Z1IAAAAASUVORK5CYII=', # rubocop:disable Layout/LineLength
            'disposition' => 'inline',
            'filename' => 'file.png',
            'content_id' => a_string_ending_with('@test.mail'),
            'type' => 'image/png'
          }
        ]
      end

      before do
        message.attachments['file.txt'] = File.read('spec/fixtures/files/attachments/file.txt')
        message.attachments.inline['file.png'] = File.read('spec/fixtures/files/attachments/file.png')
        allow(Socket).to receive(:gethostname).and_return('test')
      end

      it { is_expected.to include(*expected_json_attachment) }
    end

    describe 'text content' do
      before do
        message_params.delete(:body)
      end

      it 'has empty text by default' do
        expect(mail.text).to be_empty
        expect(mail.html).to be_nil
      end

      context 'when only text part is present' do
        before do
          message.text_part = 'Some text'
        end

        specify 'only text is present' do
          expect(mail.text).to eq('Some text')
          expect(mail.html).to be_nil
        end
      end

      context 'when only html part is present' do
        before do
          message.html_part = '<div>HTML part</div>'
        end

        specify 'only html is present' do
          expect(mail.text).to be_nil
          expect(mail.html).to eq('<div>HTML part</div>')
        end
      end

      context 'when both text and html part are present' do
        before do
          message.text_part = 'Some text'
          message.html_part = '<div>HTML part</div>'
        end

        specify 'both parts are present' do
          expect(mail.text).to eq('Some text')
          expect(mail.html).to eq('<div>HTML part</div>')
        end
      end
    end
  end
end
