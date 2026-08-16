require_relative "boot"

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "active_storage/engine"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_mailbox/engine"
require "action_text/engine"
require "action_view/railtie"
require "action_cable/engine"
require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module PlayaAutos
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 8.1

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])

    # The schema relies on PostgreSQL features that schema.rb cannot express
    # (the `vehicle_codes` sequence backing internal vehicle codes), so the
    # structure is dumped as SQL to stay reproducible from scratch.
    config.active_record.schema_format = :sql

    # The admin panel is Spanish-facing; identifiers stay in English.
    config.i18n.default_locale = :es
    config.i18n.available_locales = [ :es, :en ]
    config.i18n.fallbacks = [ :en ]

    config.time_zone = "America/Asuncion"
    config.active_record.default_timezone = :utc

    # ImageMagick rather than the Rails 8 default of libvips, which is not
    # installed on this machine. Swap back to :vips if libvips is available —
    # nothing else in the app depends on the choice.
    config.active_storage.variant_processor = :mini_magick

    # Don't generate system test files.
    config.generators.system_tests = nil
  end
end
