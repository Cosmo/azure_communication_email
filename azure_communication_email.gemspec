# frozen_string_literal: true

require_relative "lib/azure_communication_email/version"

Gem::Specification.new do |spec|
  spec.name = "azure_communication_email"
  spec.version = AzureCommunicationEmail::VERSION
  spec.authors = [ "Devran Cosmo Uenal" ]
  spec.email = [ "maccosmo@gmail.com" ]

  spec.summary = "Azure Email Communications Service Delivery Method for Action Mailer"
  spec.description = "Action Mailer delivery method using the Azure Email Communications Service."
  spec.homepage = "https://github.com/Cosmo/azure_communication_email"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.2.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ Gemfile .gitignore test/ .github/ .rubocop.yml])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = [ "lib" ]

  spec.add_dependency "base64", ">= 0.2.0"
  spec.add_dependency "activesupport", ">= 7.0"
  spec.add_dependency "actionmailer", ">= 7.0"
  spec.add_development_dependency "mail", ">= 2.8"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
