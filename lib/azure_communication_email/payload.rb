# frozen_string_literal: true

require "active_support/all"
require "json"
require "base64"

module AzureCommunicationEmail
  class Payload
    def initialize(mail)
      @mail = mail
    end

    def as_json
      hash = {
        "senderAddress" => first_address(@mail.from),
        "content" => {
          "subject"   => @mail.subject.to_s,
          "plainText" => plain_text_body
        },
        "recipients" => {
          "to" => recipient_objects(@mail.to)
        }
      }

      html = html_body
      hash["content"]["html"] = html if html.present?

      cc  = recipient_objects(@mail.cc)
      bcc = recipient_objects(@mail.bcc)
      hash["recipients"]["cc"]  = cc  if cc.present?
      hash["recipients"]["bcc"] = bcc if bcc.present?

      reply_to = recipient_objects(@mail.reply_to)
      hash["replyTo"] = reply_to if reply_to.present?

      headers = custom_headers
      hash["headers"] = headers if headers.present?

      attachments = attachment_objects
      hash["attachments"] = attachments if attachments.present?

      hash
    end

    def to_json(*args)
      JSON.generate(as_json, *args)
    end

    private

    def plain_text_body
      if @mail.text_part
        @mail.text_part.decoded
      else
        @mail.body.decoded.to_s
      end
    end

    def html_body
      @mail.html_part&.decoded
    end

    def first_address(list)
      Array(list).compact_blank.first
    end

    def recipient_objects(addresses)
      Array(addresses).compact_blank.map { |address| { "address" => address } }
    end

    def attachment_objects
      return [] unless @mail.attachments&.any?

      @mail.attachments.map do |attachment|
        {
          "name" => attachment.filename.to_s,
          "contentType" => attachment.mime_type.to_s,
          "contentInBase64" => Base64.strict_encode64(attachment.body.decoded)
        }
      end
    end

    def custom_headers
      return {} unless @mail.header

      @mail.header.fields
        .select { |field| field.name =~ /\AX-/i }
        .to_h { |field| [ field.name, field.value.to_s ] }
    end
  end
end
