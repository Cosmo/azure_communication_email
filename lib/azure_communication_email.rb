# frozen_string_literal: true

require_relative "azure_communication_email/version"
require_relative "azure_communication_email/delivery_method"

# Auto-register with Rails when loaded
if defined?(Rails) && defined?(ActionMailer)
  ActionMailer::Base.add_delivery_method :azure_communication_email, AzureCommunicationEmail::DeliveryMethod
end
