# frozen_string_literal: true

require "test_helper"

class TestAzureCommunicationEmail < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::AzureCommunicationEmail::VERSION
  end

  def test_registers_with_action_mailer_regardless_of_load_order
    require "action_mailer"

    assert_equal AzureCommunicationEmail::DeliveryMethod,
                 ActionMailer::Base.delivery_methods[:azure_communication_email]
    assert_respond_to ActionMailer::Base, :azure_communication_email_settings
  end
end
