BitcoinBank::Application.configure do
  config.cache_classes = true
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true
  config.action_dispatch.x_sendfile_header = "X-Sendfile"
  config.i18n.fallbacks = true
  config.active_support.deprecation = :notify
  config.force_ssl = false
  
  
  # configure mailer
  ENV["MANDRILL_USERNAME"] = "willmoss26@gmail.com"
  ENV["MANDRILL_PASSWORD"] = "Mnkx71AphDFJeCbWKhr75w"

  config.action_mailer.delivery_method = :smtp

  config.action_mailer.smtp_settings = {
    :port      => 587,
    :address   => "smtp.mandrillapp.com",
    :user_name => "willmoss26@gmail.com",
    :password  => "Mnkx71AphDFJeCbWKhr75w"
  }
  
  config.action_mailer.default_url_options = { :host => 'localhost:3000' }
  
  # Used to broadcast invoices public URLs
  
  # BITFICATION DEFAULTS
  config.base_url = "https://bitfication.com/"
  config.assets.initialize_on_precompile = true
  config.assets.compress = true
  config.assets.compile = false
  config.assets.digest = true
  config.serve_static_assets = false
  
  
  
end
