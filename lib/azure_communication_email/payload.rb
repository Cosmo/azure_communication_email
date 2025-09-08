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
        "senderAddress" => first_sender_address,
        "content" => {
          "subject"   => @mail.subject.to_s,
          "plainText" => plain_text_body
        },
        "recipients" => {
          "to" => recipient_objects(:to)
        }
      }

      if (html = html_body).present?
        hash["content"]["html"] = html
      end

      if (cc = recipient_objects(:cc)).present?
        hash["recipients"]["cc"] = cc
      end

      if (bcc = recipient_objects(:bcc)).present?
        hash["recipients"]["bcc"] = bcc
      end

      if (reply_to = recipient_objects(:reply_to)).present?
        hash["replyTo"] = reply_to
      end

      if (headers = custom_headers).present?
        hash["headers"] = headers
      end

      if (attachments = attachment_objects).present?
        hash["attachments"] = attachments
      end

      hash
    end

    def to_json(*args)
      JSON.generate(as_json, *args)
    end

    private

    def plain_text_body
      if @mail.text_part
        @mail.text_part.decoded.to_s
      elsif @mail.mime_type == "text/plain"
        @mail.body.decoded.to_s
      else
        ""
      end
    end

    def html_body
      if @mail.html_part
        @mail.html_part.decoded.to_s
      elsif @mail.mime_type == "text/html"
        @mail.body.decoded.to_s
      end
    end

    def address_list(field_sym)
      field = @mail[field_sym]
      return [] unless field.respond_to?(:addrs)
      field.addrs
    end

    def first_sender_address
      address_list(:from).first&.address.to_s
    end

    def recipient_objects(field_sym)
      address_list(field_sym).map do |addr|
        obj = { "address" => addr.address.to_s }
        name = addr.display_name.to_s.strip
        obj["displayName"] = name if name.present?
        obj
      end
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
