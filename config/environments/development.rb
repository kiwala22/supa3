Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports.
  config.consider_all_requests_local = true


  ##disable rack attack in development environment
  Rack::Attack.enabled = false

  # Enable/disable caching. By default caching is disabled.
  # Run rails dev:cache to toggle caching.
  if Rails.root.join('tmp', 'caching-dev.txt').exist?
    config.action_controller.perform_caching = true

    config.cache_store = :memory_store
    config.public_file_server.headers = {
      'Cache-Control' => "public, max-age=#{2.days.to_i}"
    }
  else
    config.action_controller.perform_caching = false

    config.cache_store = :null_store
  end

  # Store uploaded files on the local file system (see config/storage.yml for options)
  config.active_storage.service = :local

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = false

  config.action_mailer.perform_caching = false

   config.log_level = :debug

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Highlight code that triggered database queries in logs.
  config.active_record.verbose_query_logs = true

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.assets.debug = true

  # Suppress logger output for asset requests.
  config.assets.quiet = true

  # Raises error for missing translations
  # config.action_view.raise_on_missing_translations = true

  # Use an evented file watcher to asynchronously detect changes in source code,
  # routes, locales, etc. This feature depends on the listen gem.
  config.file_watcher = ActiveSupport::EventedFileUpdateChecker

  # Add the fonts path
  config.assets.paths << Rails.root.join('app', 'assets', 'fonts')

  ## setup action_mailer
  # config.action_mailer.delivery_method = :sendmail
  # config.action_mailer.default_url_options = { :host => 'localhost:3000' }
  # Rails.application.routes.default_url_options[:host] = 'localhost:3000'
  # config.action_mailer.perform_deliveries = true
  config.action_mailer.raise_delivery_errors = true
  #config.action_mailer.default_url_options = { :host => 'localhost', protocol: 'http' }

  config.action_mailer.perform_caching = false




  #mailer Defaults
  config.action_mailer.default_url_options = { :host => 'skylinesms.com' }
  Rails.application.routes.default_url_options[:host] = 'skylinesms.com'

  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = {
    address:              'smtp.elasticemail.com',
    port:                 2525,
    domain:               'skylinesms.com',
    user_name:            'acaciabengo@gmail.com',
    password:             '77eea235-c9b6-40db-8405-30cbafbfb8fb',
    authentication:       'plain',
    enable_starttls_auto: true  }
  config.action_mailer.perform_deliveries = true

end
