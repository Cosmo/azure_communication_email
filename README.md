# Azure Communication Email

Azure Communication Email is an Action Mailer delivery method for Ruby on Rails using the [Azure Email Communications Service](https://learn.microsoft.com/en-us/azure/communication-services/quickstarts/email/create-email-communication-resource?pivots=platform-azp).

## Installation

Install the gem and add to your application's Gemfile by executing:

```bash
bundle add azure_communication_email
```

Or add it manually to your Gemfile:

```ruby
gem "azure_communication_email"
```

## Configuration

Create an Azure Communication Services resource, connect a verified email domain, and configure the delivery method in the environment where email should be sent:

```ruby
# config/environments/production.rb

Rails.application.configure do
  config.action_mailer.delivery_method = :azure_communication_email
  config.action_mailer.azure_communication_email_settings = {
    endpoint: ENV.fetch("ACS_EMAIL_ENDPOINT"),
    access_key: ENV.fetch("ACS_EMAIL_ACCESS_KEY")
  }
end
```

`endpoint` is the complete Communication Services endpoint, for example `https://my-resource.communication.azure.com`. `access_key` is one of that resource's access keys.

The optional `api_version` setting defaults to `2025-01-15-preview`. This version is used because it supports sender display names for custom domains.

Keep `config.action_mailer.delivery_method = :test` in the test environment so tests do not send real email.

## Usage

Use Action Mailer normally; no Azure-specific mailer class is needed:

```ruby
class UserMailer < ApplicationMailer
  def welcome_email(user)
    @user = user
    mail(to: @user.email, from: "donotreply@<yourdomain>.com", subject: "Hello World!")
  end
end
```

Send through Active Job in most application code:

```ruby
UserMailer.with(user: user).welcome_email.deliver_later
```

The delivery method maps Action Mailer messages to Azure, including:

- plain-text and HTML bodies, including multipart messages
- `to`, `cc`, `bcc`, and `reply_to` recipients with display names
- regular and inline attachments
- `X-` custom headers
- a sender display name when using a custom domain

Azure limits the total request size, including attachments, to 10 MB.

## Delivery status and errors

Azure accepts email asynchronously. A successful `deliver_now` or delivery job means Azure returned `202 Accepted`; it does not guarantee final delivery to the recipient. Use Azure Monitor or Event Grid email events for final delivery and bounce tracking.

Configuration errors, connection failures, timeouts, authentication failures, and non-successful HTTP responses raise `AzureCommunicationEmail::Error`. The HTTP connection timeout is 5 seconds and the response timeout is 15 seconds.

For a quick production check, send a message from the Rails console with `deliver_now`. Use a verified sender address and inspect Azure's email logs if the recipient does not receive it.

## Links

- [Service limits for Azure Communication Services](https://learn.microsoft.com/en-us/azure/communication-services/concepts/service-limits#email)
- [Monitor Azure Communication Services email events](https://learn.microsoft.com/en-us/azure/communication-services/concepts/email/email-event-data)
- [How to add and remove Multiple Sender Addresses to Email Communication Service](https://learn.microsoft.com/en-us/azure/communication-services/quickstarts/email/add-multiple-senders?pivots=platform-azp)

## Contributing

Bug reports and pull requests are welcome.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
