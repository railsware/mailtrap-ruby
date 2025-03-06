# frozen_string_literal: true

RSpec.describe Mailtrap::Client do
  subject(:client) { described_class.new(api_key:) }

  let(:api_key) { 'correct-api-key' }

  describe '#send', :vcr do
    subject(:send) { client.send(mail) }

    context 'when mail' do
      let(:mail) do
        Mailtrap::Mail::Base.new(
          from: { email: 'mailtrap@mailtrap.io', name: 'Mailtrap Test' },
          to: [
            { email: 'mailtrap@railsware.com' }
          ],
          subject: 'You are awesome!',
          text: 'Congrats for sending test email with Mailtrap!',
          category: 'Integration Test',
          attachments: [
            { content: StringIO.new('hello world'), filename: 'attachment.txt' }
          ]
        )
      end

      context 'when all params are set' do
        it 'sending is successful' do
          expect(send).to eq({ message_ids: ['4c2446b6-e0f9-11ec-9487-0a58a9feac02'], success: true })
        end
      end

      context 'when no subject and no text set' do
        before do
          mail.subject = nil
          mail.text = nil
        end

        it 'raises sending error with array of errors' do
          expect { send }.to raise_error do |error|
            expect(error).to be_a(Mailtrap::Error)
            expect(error.message).to eq("'subject' is required, must specify either text or html body")
            expect(error.messages).to eq(["'subject' is required", 'must specify either text or html body'])
          end
        end
      end

      context 'when api key is incorrect' do
        let(:api_key) { 'incorrect-api-key' }

        it 'raises authorization error with array of errors' do
          expect { send }.to raise_error do |error|
            expect(error).to be_a(Mailtrap::AuthorizationError)
            expect(error.message).to eq('Unauthorized')
            expect(error.messages).to eq(['Unauthorized'])
          end
        end
      end

      context 'when mail object is not a Mailtrap::Mail::Base' do
        let(:mail) { 'it-a-string' }

        it { expect { send }.to raise_error(ArgumentError, 'should be Mailtrap::Mail::Base object') }
      end

      context 'with an alternative host' do
        let(:client) do
          described_class.new(api_key:, api_host: 'alternative.host.mailtrap.io', api_port: 8080)
        end

        it 'sending is successful' do
          expect(send).to eq({ message_ids: ['867394cd-4b43-11ed-af38-0a58a9feac02'], success: true })
        end
      end

      context 'with bulk flag' do
        let(:client) do
          described_class.new(api_key:, bulk: true)
        end

        it 'chooses host for bulk sending' do
          expect(send).to eq({ success: true })
        end
      end

      context 'with bulk flag and alternative host' do
        let(:client) do
          described_class.new(api_key:, bulk: true, api_host: 'alternative.host.mailtrap.io', api_port: 8080)
        end

        it 'chooses alternative host' do
          expect(send).to eq({ success: true })
        end
      end

      context 'with sandbox flag' do
        let(:client) do
          described_class.new(api_key:, sandbox: true, inbox_id: 12)
        end

        it 'chooses host for sandbox sending' do
          expect(send).to eq({ success: true })
        end
      end

      context 'with sandbox flag without inbox id' do
        let(:client) do
          described_class.new(api_key:, sandbox: true)
        end

        it { expect { send }.to raise_error(ArgumentError, 'inbox_id is required for sandbox API') }
      end

      context 'with bulk and sandbox flag' do
        let(:client) do
          described_class.new(api_key:, bulk: true, sandbox: true)
        end

        it { expect { send }.to raise_error(ArgumentError, 'bulk mode is not applicable for sandbox API') }
      end
    end

    context 'when template' do
      let(:mail) do
        Mailtrap::Mail::FromTemplate.new(
          from: { email: 'mailtrap@mailtrap.io', name: 'Mailtrap Test' },
          to: [
            { email: 'mailtrap@railsware.com' }
          ],
          attachments: [
            { content: StringIO.new('hello world'), filename: 'attachment.txt' }
          ],
          template_uuid: 'aeb1ec59-2737-4a1d-9c95-0baf3be49d74',
          template_variables: { 'user_name' => 'John Doe' }
        )
      end

      context 'when all params are set' do
        it 'sending is successful' do
          expect(send).to eq({ message_ids: ['617103b5-7b2c-11ed-b344-0242ac1c0107'], success: true })
        end
      end

      context 'when api key is incorrect' do
        let(:api_key) { 'incorrect-api-key' }

        it 'raises authorization error with array of errors' do
          expect { send }.to raise_error do |error|
            expect(error).to be_a(Mailtrap::AuthorizationError)
            expect(error.message).to eq('Unauthorized')
            expect(error.messages).to eq(['Unauthorized'])
          end
        end
      end

      context 'when using sandbox' do
        let(:client) do
          described_class.new(api_key:, sandbox: true, inbox_id: 13)
        end

        it 'sending is successful' do
          expect(send).to eq({ message_ids: ['617103b5-7b2c-11ed-b344-0242ac1c0107'], success: true })
        end
      end
    end
  end

  describe 'errors' do
    subject(:send_mail) { client.send(mail) }

    let(:mail) do
      Mailtrap::Mail::Base.new(
        from: { email: 'from@example.com' },
        to: [{ email: 'to@example.com' }],
        subject: 'Test',
        text: 'Test'
      )
    end

    def stub_api_send(status, body = nil)
      stub = stub_request(:post, %r{/api/send}).to_return(status:, body:)
      yield
      expect(stub).to have_been_requested
    end

    it 'handles 400' do
      stub_api_send 400, '{"errors":["error"]}' do
        expect { send_mail }.to raise_error(Mailtrap::Error)
      end
    end

    it 'handles 401' do
      stub_api_send 401, '{"errors":["Unauthorized"]}' do
        expect { send_mail }.to raise_error(Mailtrap::AuthorizationError)
      end
    end

    it 'handles 403' do
      stub_api_send 403, '{"errors":["Account is banned"]}' do
        expect { send_mail }.to raise_error(Mailtrap::RejectionError)
      end
    end

    it 'handles 413' do
      stub_api_send 413 do
        expect { send_mail }.to raise_error(Mailtrap::MailSizeError)
      end
    end

    it 'handles 429' do
      stub_api_send 429 do
        expect { send_mail }.to raise_error(Mailtrap::RateLimitError)
      end
    end

    it 'handles generic client errors' do
      stub_api_send 418, '🫖' do
        expect { send_mail }.to raise_error(Mailtrap::Error, 'client error')
      end
    end

    it 'handles server errors' do
      stub_api_send 504, '🫖' do
        expect { send_mail }.to raise_error(Mailtrap::Error, 'server error')
      end
    end

    it 'handles unexpected response status code' do
      stub_api_send 307 do
        expect { send_mail }.to raise_error(Mailtrap::Error, 'unexpected status code=307')
      end
    end
  end
end
