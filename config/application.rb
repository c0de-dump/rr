require_relative 'boot'

require 'rails/all'
require 'zipkin-tracer'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Store
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 8.0

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    # Configure and add Zipkin middleware for distributed tracing
    zipkin_config = {
      service_name: 'rails-store',      # Required - the name of this application
      service_port: 3000,               # Default port the service runs on
      json_api_host: 'http://zipkin:9411', # Zipkin collector host
      sample_rate: 1.0, # Sample rate, 1.0 means sample all requests
      # logger: Rails.logger,
      sampled_as_boolean: false
      # log_tracing: true
    }
    config.middleware.use ZipkinTracer::RackHandler, zipkin_config
  end
end
