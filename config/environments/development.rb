TinyMon::Application.configure do
  # Settings specified here will take precedence over those in config/environment.rb

  # In the development environment your application's code is reloaded on
  # every request.  This slows down response time but is perfect for development
  # since you don't have to restart the webserver when you make code changes.
  config.cache_classes = false
  config.assets.compile = true
  config.eager_load = false
  config.serve_static_assets = true
  # Do not compress assets
  config.assets.compress = false

  # Expands the lines which load the assets
  config.assets.debug = false

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send
  config.action_mailer.raise_delivery_errors = false

  config.action_mailer.default_url_options = { :host => 'http://localhost:5000' }
  config.action_mailer.delivery_method = :file
  config.action_mailer.default_options = { :from => 'no-reply@tinymon.org' }

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log
end
