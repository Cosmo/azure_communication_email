# frozen_string_literal: true

require_relative "azure_communication_email/version"
require_relative "azure_communication_email/delivery_method"

ActiveSupport.on_load(:action_mailer) do
  add_delivery_method :azure_communication_email, AzureCommunicationEmail::DeliveryMethod
end
