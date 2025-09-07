# Azure Communication Email

Azure Communication Email is an Action Mailer delivery method for Ruby on Rails using the Azure Communication Email API.

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
    endpoint:   ENV.fetch("ACS_EMAIL_ENDPOINT"),
    access_key: ENV.fetch("ACS_EMAIL_ACCESS_KEY"),
  }
end
```

## Contributing

Bug reports and pull requests are welcome.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
