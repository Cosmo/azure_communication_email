# frozen_string_literal: true

require "test_helper"

class TestDeliveryMethod < Minitest::Test
  FakeHttp = Struct.new(:response, :use_ssl, :open_timeout, :read_timeout, :last_request) do
    def request(request)
      self.last_request = request
      response
    end
  end

  def test_posts_the_mail_to_azure
    response = Net::HTTPAccepted.new("1.1", "202", "Accepted")
    http = FakeHttp.new(response)
    delivery_method = AzureCommunicationEmail::DeliveryMethod.new(
      endpoint: "https://example.communication.azure.com",
      access_key: Base64.strict_encode64("secret")
    )

    Net::HTTP.stub(:new, http) do
      assert_same response, delivery_method.deliver!(mail)
    end

    assert http.use_ssl
    assert_equal 5, http.open_timeout
    assert_equal 15, http.read_timeout
    assert_equal "/emails:send?api-version=2025-01-15-preview", http.last_request.path
    assert_equal "application/json", http.last_request["Content-Type"]
    assert_equal "Hello", JSON.parse(http.last_request.body).dig("content", "subject")
  end

  def test_raises_the_azure_error_from_an_unsuccessful_response
    response = Struct.new(:code, :message, :body).new("400", "Bad Request", "invalid sender")
    http = FakeHttp.new(response)
    delivery_method = AzureCommunicationEmail::DeliveryMethod.new(
      endpoint: "https://example.communication.azure.com",
      access_key: Base64.strict_encode64("secret")
    )

    error = Net::HTTP.stub(:new, http) do
      assert_raises(AzureCommunicationEmail::Error) { delivery_method.deliver!(mail) }
    end

    assert_equal "Failed to send email: 400 Bad Request - invalid sender", error.message
  end

  private

  def mail
    Mail.new do
      from "sender@example.com"
      to "recipient@example.com"
      subject "Hello"
      body "Hello there"
    end
  end
end
