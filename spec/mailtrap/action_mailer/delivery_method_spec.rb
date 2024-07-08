# frozen_string_literal: true

require 'mailtrap/action_mailer'

RSpec.describe Mailtrap::ActionMailer::DeliveryMethod, :vcr do
  describe '#deliver!' do
    subject(:deliver!) { described_class.new(settings).deliver!(message) }

    let(:settings) { { api_key: 'correct-api-key' } }
    let(:message) do
      Mail::Message.new(params).tap do |message|
        message.text_part = 'Some text'
        message.html_part = '<div>HTML part</div>'
        message.headers('X-Special-Domain-Specific-Header': 'SecretValue')
        message.headers('One-more-custom-header': 'CustomValue')
        message.attachments['file.txt'] = File.read('spec/fixtures/files/attachments/file.txt')
        message.attachments['file.txt'].content_id = '<txt_content_id@test.mail>'
        message.attachments.inline['file.png'] = File.read('spec/fixtures/files/attachments/file.png')
        message.attachments['file.png'].content_id = '<png_content_id@test.mail>'
      end
    end
    let(:params) do
      {
        from: 'Mailtrap Test <mailtrap@mailtrap.io>',
        to: 'To 1 <to_1@railsware.com>, to_2@railsware.com',
        cc: 'cc_1@railsware.com, Cc 2 <cc_2@railsware.com>',
        bcc: 'bcc_1@railsware.com, bcc_2@railsware.com',
        reply_to: 'reply-to@railsware.com',
        subject: 'You are awesome!',
        category: 'Module Test'
      }
    end
    let(:expected_message_ids) do
      %w[
        858cbc46-09d5-11ed-91e0-0a58a9feac02
        858cbc5c-09d5-11ed-91e0-0a58a9feac02
        858cbc6d-09d5-11ed-91e0-0a58a9feac02
        858cbc7e-09d5-11ed-91e0-0a58a9feac02
        858cbc90-09d5-11ed-91e0-0a58a9feac02
        858cbca1-09d5-11ed-91e0-0a58a9feac02
      ]
    end

    before do
      allow(Mail::ContentTypeField).to receive(:generate_boundary).and_return('--==_mimepart_random_boundary')
      allow(Mailtrap::Client).to receive(:new).and_call_original
    end

    it 'converts the message and sends via API' do
      expect(deliver!).to eq({ success: true, message_ids: expected_message_ids })
      expect(Mailtrap::Client).to have_received(:new).with(api_key: 'correct-api-key')
    end
  end
end
