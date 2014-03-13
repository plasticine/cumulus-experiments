require File.expand_path('../boot', __FILE__)

require "action_controller/railtie"
require "action_mailer/railtie"
require "sprockets/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, Rails.env)

module Cumulus
  class Application < Rails::Application
    # Include the 'lib' dir in the autoload path.
    config.autoload_paths += %W(#{config.root}/lib)
  end
end
