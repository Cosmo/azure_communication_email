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
    assert_equal [ { "address" => "to@example.com" } ], json["recipients"]["to"]
    refute json["content"].key?("html"), "html should be omitted when not present"
  end

  def test_multipart_html_and_text
    mail = Mail.new do
      from    "from@example.com"
      to      "to@example.com"
      subject "Hello"

      text_part do
        body "plain body"
      end

      html_part do
        content_type "text/html; charset=UTF-8"
        body "<p>html body</p>"
      end
    end

    json = AzureCommunicationEmail::Payload.new(mail).as_json
    assert_equal "plain body", json["content"]["plainText"]
    assert_equal "<p>html body</p>", json["content"]["html"]
  end

  def test_html_only_message
    mail = Mail.new do
      from         "from@example.com"
      to           "to@example.com"
      subject      "Hello"
      content_type "text/html; charset=UTF-8"
      body         "<h1>hi</h1>"
    end

    json = AzureCommunicationEmail::Payload.new(mail).as_json
    assert_equal "<h1>hi</h1>", json["content"]["html"]
    assert_equal "", json["content"]["plainText"] # HTML-only
  end

  def test_text_only_message
    mail = Mail.new do
      from         "from@example.com"
      to           "to@example.com"
      subject      "Hello Text"
      content_type "text/plain; charset=UTF-8"
      body         "only text"
    end

    json = AzureCommunicationEmail::Payload.new(mail).as_json
    assert_equal "only text", json["content"]["plainText"]
    refute json["content"].key?("html"), "html should be omitted for pure text emails"
  end

  def test_attachments_and_headers
    mail = Mail.new do
      from "a@x.com"; to "b@x.com"; subject "S"
      header["X-Trace-Id"] = "t-1"
      add_file filename: "a.txt", content: "hello"
      body "b"
    end

    json = AzureCommunicationEmail::Payload.new(mail).as_json
    assert_equal({ "X-Trace-Id" => "t-1" }, json["headers"])
    att = json["attachments"].first
    assert_equal "a.txt", att["name"]
    assert_equal "text/plain", att["contentType"]
    refute_nil att["contentInBase64"]
  end
end
