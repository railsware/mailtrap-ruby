# frozen_string_literal: true

require 'base64'
require 'json'

module Mailtrap
  class Attachment
    attr_accessor :type, :filename, :disposition, :content_id
    attr_reader :content

    def initialize(content:, filename:, type: nil, disposition: nil, content_id: nil)
      self.content = content
      @type = type
      @filename = filename
      @disposition = disposition
      @content_id = content_id
    end

    def as_json
      {
        'content' => content,
        'type' => type,
        'filename' => filename,
        'disposition' => disposition,
        'content_id' => content_id
      }.compact
    end

    def content=(content)
      if content.respond_to?(:read)
        @content = encode(content)
      else
        raise AttachmentContentError unless base64?(content)

        @content = content
      end
    end

    private

    def encode(io)
      string = io.read.encode('UTF-8') unless io.respond_to?(:binmode?) && io.binmode?
      Base64.encode64(string).gsub(/\n/, '')
    end

    def base64?(string)
      string.is_a?(String) && Base64.strict_encode64(Base64.decode64(string)) == string
    end
  end
end
