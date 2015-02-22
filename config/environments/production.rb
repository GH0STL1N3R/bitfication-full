BitcoinBank::Application.configure do
  # Settings specified here will take precedence over those in config/environment.rb

  # In the development environment your application's code is reloaded on
  # every request.  This slows down response time but is perfect for development
  # since you don't have to restart the webserver when you make code changes.
  config.cache_classes = true

  # Show full error reports and disable caching
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  config.action_dispatch.x_sendfile_header = "X-Sendfile"
  config.i18n.fallbacks = true

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :notify

  # If SSL is required, set this to true
  config.force_ssl = true

  # It will manage cache for us with memcached
  config.cache_store = :dalli_store, 'localhost'

  # Uncomment this to test e-mails in development mode
  config.action_mailer.delivery_method = :sendmail
  config.action_mailer.default_url_options = {
    :host => "bitfication.com"
  }

  config.middleware.use ::ExceptionNotification::Rack,
    :email => {
      :email_prefix => "[BF Exception] ",
      :sender_address => %w{no-reply@bitfication.com},
      :exception_recipients => %w{support@bitfication.com}
    }

  # Used to broadcast invoices public URLs
  config.base_url = "https://bitfication.com/"

  config.assets.initialize_on_precompile = true
  config.assets.compress = true
  config.assets.compile = false
  config.assets.digest = true
  config.serve_static_assets = false
end
