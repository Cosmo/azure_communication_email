# frozen_string_literal: true

require "uri"
require "openssl"
require "base64"
require "time"

# HMAC authentication for Azure Communication Services Email REST API
#
# Reference:
# https://learn.microsoft.com/en-us/azure/communication-services/tutorials/hmac-header-tutorial?pivots=programming-language-python

module AzureCommunicationEmail
  class HmacAuth
    def initialize(endpoint:, access_key:)
      @endpoint = endpoint # e.g. "https://my-resource.communication.azure.com"
      @access_key = access_key
    end

    # body: must be the exact JSON string that will go in request.body
    def sign_request(http_method:, path_and_query:, body:)
      uri = URI.join(@endpoint, path_and_query)

      content_bytes = body.encode("utf-8")

      # RFC1123 UTC timestamp
      date = Time.now.utc.httpdate

      # Base64(SHA256(request-body-bytes))
      content_hash = base64_sha256(content_bytes)

      # StringToSign
      host = uri.host.downcase
      string_to_sign = [
        http_method.upcase,
        path_and_query,
        "#{date};#{host};#{content_hash}"
      ].join("\n")

      signature = base64_hmac_sha256(string_to_sign, @access_key)

      authorization_header = "HMAC-SHA256 SignedHeaders=x-ms-date;host;x-ms-content-sha256&Signature=#{signature}"

      {
        "x-ms-date" => date,
        "x-ms-content-sha256" => content_hash,
        "Authorization" => authorization_header,
        "Content-Type" => "application/json"
      }
    end

    private

    def base64_sha256(bytes)
      digest = OpenSSL::Digest::SHA256.digest(bytes)
      Base64.strict_encode64(digest)
    end

    def base64_hmac_sha256(string_to_sign, base64_secret)
      secret = Base64.decode64(base64_secret)
      hmac   = OpenSSL::HMAC.digest("sha256", secret, string_to_sign.encode("utf-8"))
      Base64.strict_encode64(hmac)
    end
  end
end
