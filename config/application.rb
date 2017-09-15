require_relative 'boot'

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_view/railtie"
require "action_cable/engine"
require "rails/test_unit/railtie"

Bundler.require(*Rails.groups)

module DefensoriaApi
  class Application < Rails::Application
    config.api_only = true
    config.time_zone = 'America/Argentina/Buenos_Aires'
    config.active_record.time_zone_aware_types = [:datetime, :time]
    config.i18n.default_locale = :es
    config.encoding = "utf-8"
    config.autoload_paths += Dir[Rails.root.join('app', 'services', '{*/}')]
    config.autoload_paths += Dir[Rails.root.join('app', 'models', '{*/}')]
  end
end
