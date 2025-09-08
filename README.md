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

## Usage

To send emails using Azure Communication Services, configure Action Mailer with the `:azure_communication_email` delivery method and provide the necessary credentials.

```ruby
# config/environments/production.rb

Rails.application.configure do
  config.action_mailer.delivery_method = :azure_communication_email
  config.action_mailer.azure_communication_email_settings = {
    endpoint:   ENV.fetch("ACS_EMAIL_ENDPOINT"), # e.g., "https://<RESOURCE_NAME>.communication.azure.com"
    access_key: ENV.fetch("ACS_EMAIL_ACCESS_KEY"),
  }
end
```

Then, you can use Action Mailer as usual:

```ruby
class UserMailer < ApplicationMailer
  def welcome_email(user)
    @user = user
    mail(to: @user.email, from: "donotreply@<yourdomain>.com", subject: "Hello World!")
  end
end
```

## Links

- [Service limits for Azure Communication Services](https://learn.microsoft.com/en-us/azure/communication-services/concepts/service-limits#email)
- [How to add and remove Multiple Sender Addresses to Email Communication Service](https://learn.microsoft.com/en-us/azure/communication-services/quickstarts/email/add-multiple-senders?pivots=platform-azp)

## Contributing

Bug reports and pull requests are welcome.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
