# frozen_string_literal: true

require File.expand_path("boot", __dir__)

# Pick the frameworks you want:
require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_view/railtie"
# require "rails/test_unit/railtie"

Bundler.require(*Rails.groups)
require "pages_core"

module Internal
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 8.0

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])

    # Settings in config/environments/* take precedence over those
    # specified here.  Application configuration should go into files
    # in config/initializers -- all .rb files in that directory are
    # automatically loaded.

    # Set Time.zone default to the specified zone and make Active
    # Record auto-convert to this zone.  Run "rake -D time" for a list
    # of tasks for finding time zone names. Default is UTC.
    config.time_zone = "Copenhagen"

    # The default locale is :en and all translations from
    # config/locales/*.rb,yml are auto loaded.

    # config.i18n.load_path += Dir[
    #   Rails.root.join('my', 'locales', '*.{rb,yml}').to_s
    # ]
    config.i18n.default_locale = :nb
  end
end
