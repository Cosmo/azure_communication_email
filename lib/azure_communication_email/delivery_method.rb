# frozen_string_literal: true

require_relative "payload"
require_relative "hmac_auth"
require_relative "error"

require "active_support/all"
require "net/http"
require "uri"

module AzureCommunicationEmail
  class DeliveryMethod
    DEFAULTS = { api_version: "2023-03-31" }

    attr_accessor :endpoint, :api_version, :access_key

    def initialize(values)
      @endpoint     = values.fetch(:endpoint)
      @api_version  = values.fetch(:api_version, DEFAULTS[:api_version])
      @access_key   = values.fetch(:access_key)
    end

    def deliver!(mail)
      raise ArgumentError, "Missing :endpoint configuration (https://my-resource.communication.azure.com)" if @endpoint.blank?
      raise ArgumentError, "Missing :access_key configuration" if @access_key.blank?

      path_and_query = "/emails:send?api-version=#{@api_version}"
      uri = URI.join(@endpoint, path_and_query)

      # Prepare email payload
      payload = Payload.new(mail)
      body_json = payload.to_json

      # Sign request
      hmac_auth = HmacAuth.new(endpoint: @endpoint, access_key: @access_key)
      headers = hmac_auth.sign_request(
        http_method: "POST",
        path_and_query: path_and_query,
        body: body_json
      )

      # Azure Communication Services Email
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = (uri.scheme == "https")
      request = Net::HTTP::Post.new(uri.request_uri, headers)
      request.body = body_json

      response = http.request(request)
      unless response.is_a?(Net::HTTPSuccess) || response.is_a?(Net::HTTPAccepted)
        raise Error, "Failed to send email: #{response.code} #{response.message} - #{response.body}"
      end

      response
    rescue StandardError => e
      raise Error, "Error sending email: #{e.message}"
    end
  end
end
