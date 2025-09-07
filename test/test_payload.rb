# frozen_string_literal: true

require "test_helper"

class TestPayload < Minitest::Test
  def test_basic_shape
    mail = Mail.new do
      from    "from@example.com"
      to      "to@example.com"
      subject "Hi"
      body    "plain"
    end

    json = AzureCommunicationEmail::Payload.new(mail).as_json
    assert_equal "from@example.com", json["senderAddress"]
    assert_equal "Hi", json["content"]["subject"]
    assert_equal "plain", json["content"]["plainText"]
    assert_equal [ { "address"=>"to@example.com" } ], json["recipients"]["to"]
  end

  def test_attachments_and_headers
    mail = Mail.new do
      from "a@x.com"; to "b@x.com"; subject "S"
      header["X-Trace-Id"] = "t-1"
      add_file filename: "a.txt", content: "hello"
      body "b"
    end

    json = AzureCommunicationEmail::Payload.new(mail).as_json
    assert_equal({ "X-Trace-Id"=>"t-1" }, json["headers"])
    att = json["attachments"].first
    assert_equal "a.txt", att["name"]
    assert_equal "text/plain", att["contentType"]
    refute_nil att["contentInBase64"]
  end
end
