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

        it { expect { send }.to raise_error(ArgumentError, 'bulk stream is not applicable for sandbox API') }
      end
    end

    context 'when mail is hash' do
      let(:mail) do
        {
          from: { email: 'mailtrap@mailtrap.io', name: 'Mailtrap Test' },
          to: [
            { email: 'mailtrap@railsware.com' }
          ],
          subject: 'You are awesome!',
          text: 'Congrats for sending test email with Mailtrap!',
          category: 'Integration Test',
          attachments: [
            { content: Base64.strict_encode64('hello world'), filename: 'attachment.txt' }
          ]
        }
      end

      it 'sends an email' do
        expect(send).to eq({ message_ids: ['4c2446b6-e0f9-11ec-9487-0a58a9feac02'], success: true })
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
    let(:send_mail) { client.send(mail) }
    let(:mail) do
      Mailtrap::Mail::Base.new(
        from: { email: 'from@example.com' },
        to: [{ email: 'to@example.com' }],
        subject: 'Test',
        text: 'Test'
      )
    end

    def stub_api_send(status, body = nil, &block)
      stub_post(%r{/api/send}, status, body, &block)
    end

    def stub_post(path, status, body)
      stub = stub_request(:post, path).to_return(status:, body:)
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

    it 'handles 400 with empty response body' do
      stub_post %r{/api/test}, 400, '' do
        expect { client.post('/api/test') }.to raise_error do |error|
          expect(error).to be_a(Mailtrap::Error)
          expect(error.message).to eq('bad request')
          expect(error.messages).to eq(['bad request'])
        end
      end
    end

    it 'handles general API 403' do
      stub_post %r{/api/test}, 403, '{"errors":"Account access forbidden"}' do
        expect { client.post('/api/test') }.to raise_error(Mailtrap::RejectionError)
      end
    end

    it 'handles generic client errors' do
      stub_api_send 418, '🫖' do
        expect { send_mail }.to raise_error(Mailtrap::Error, "client error '🫖'")
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

  describe '#send_batch' do
    let(:api_key) { ENV.fetch('MAILTRAP_API_KEY', 'correct-api-key') }
    let(:base_mail) do
      Mailtrap::Mail::Base.new(
        from: {
          email: 'mailtrap@demomailtrap.co',
          name: 'Mailtrap'
        },
        subject: 'Batch Subject',
        text: 'Batch Text'
      )
    end
    let(:recipients) do
      [
        Mailtrap::Mail::Base.new(
          to: [
            {
              email: ENV.fetch('MAILTRAP_TO_EMAIL', 'to@mail.com'),
              name: 'recipient1'
            }
          ]
        ),
        Mailtrap::Mail::Base.new(
          to: [
            {
              email: ENV.fetch('MAILTRAP_TO_EMAIL', 'to@mail.com'),
              name: 'recipient2'
            }
          ]
        )
      ]
    end

    context 'when bulk and sandbox modes are used together' do
      let(:client) do
        described_class.new(
          api_key:,
          bulk: true,
          sandbox: true
        )
      end

      it 'raises an error' do
        expect do
          client.send_batch(base_mail, recipients)
        end.to raise_error(ArgumentError, 'bulk stream is not applicable for sandbox API')
      end
    end

    context 'when in bulk stream' do
      let(:client) { described_class.new(api_key:, bulk: true) }

      it 'successfully sends a batch of emails', :vcr do
        response = client.send_batch(base_mail, recipients)
        expect(response).to include(
          success: true,
          responses: array_including(
            hash_including(
              success: true,
              message_ids: array_including(kind_of(String))
            )
          )
        )
      end
    end

    context 'when in sandbox mode' do
      let(:client) { described_class.new(api_key:, sandbox: true, inbox_id: 3_861_666) }

      it 'successfully sends a batch of emails', :vcr do
        response = client.send_batch(base_mail, recipients)
        expect(response).to include(
          success: true,
          responses: array_including(
            hash_including(
              success: true,
              message_ids: array_including(kind_of(String))
            )
          )
        )
      end
    end

    context 'with template' do
      let(:client) { described_class.new(api_key:, bulk: true) }
      let(:template_mail) do
        Mailtrap::Mail::Base.new(
          from: {
            email: 'mailtrap@demomailtrap.co',
            name: 'Mailtrap'
          },
          template_uuid: ENV.fetch('MAILTRAP_TEMPLATE_UUID', 'be5ed4dd-b374-4856-928d-f0957304123d'),
          template_variables: {
            company_name: 'Mailtrap'
          }
        )
      end

      it 'successfully sends a batch of emails with template', :vcr do
        response = client.send_batch(template_mail, recipients)
        expect(response).to include(
          success: true,
          responses: array_including(
            hash_including(
              success: true,
              message_ids: array_including(kind_of(String))
            )
          )
        )
      end
    end

    context 'with API errors' do
      let(:client) { described_class.new(api_key:, bulk: true) }
      let(:invalid_mail) do
        Mailtrap::Mail::Base.new(
          text: 'Batch Text'
        )
      end

      it 'handles API errors', :vcr do
        response = client.send_batch(invalid_mail, recipients)
        expect(response).to include(
          success: true,
          responses: array_including(
            hash_including(
              success: false,
              errors: array_including(
                "'from' is required",
                "'subject' is required"
              )
            )
          )
        )
      end
    end
  end
end
