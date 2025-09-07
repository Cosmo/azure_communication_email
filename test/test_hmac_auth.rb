# frozen_string_literal: true

require "test_helper"

class TestHmacAuth < Minitest::Test
  def test_signs_headers
    auth = AzureCommunicationEmail::HmacAuth.new(
      endpoint: "https://x.communication.azure.com",
      access_key: Base64.strict_encode64("secret")
    )

    fixed = Time.utc(2025, 1, 1, 0, 0, 0)
    Time.stub(:now, fixed) do
      body = '{"a":1}'
      headers = auth.sign_request(http_method: "POST", path_and_query: "/emails:send?api-version=2023-03-31", body: body)
      assert_match(/\A[A-Z][a-z]{2}, /, headers["x-ms-date"]) # RFC1123-ish
      assert headers["x-ms-content-sha256"]
      assert_match(/\AHMAC-SHA256 /, headers["Authorization"])
    end
  end
end
