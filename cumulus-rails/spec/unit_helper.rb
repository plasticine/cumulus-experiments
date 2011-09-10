require 'spec_helper'
require 'webmock/rspec'

RSpec.configure do |config|
  config.mock_with :rspec

  # Define a global around hook which runs each example inside a transaction.
  config.around do |example|
    Sequel::Model.db.transaction do
      example.run
      raise Sequel::Error::Rollback
    end
  end

  config.include RSpec::Rails::ControllerExampleGroup, type: :controller, example_group: {
    file_path: config.escaped_path(%w[spec unit controllers])
  }

  config.include RSpec::Rails::MailerExampleGroup, type: :mailer, example_group: {
    file_path: config.escaped_path(%w[spec unit mailers])
  }

  config.include RSpec::Rails::ModelExampleGroup, type: :model, example_group: {
    file_path: config.escaped_path(%w[spec unit models])
  }
end
