HaikuVillage::Application.configure do
  config.cache_classes = true

  config.action_controller.consider_all_requests_local = false
  config.action_controller.perform_caching             = true

  config.action_mailer.raise_delivery_errors = false

  config.action_mailer.smtp_settings = {
    :address        => "mail.spiz.us",
    :port           => 587,
    :domain         => "haikuvillage.com",
    :user_name      => "village",
    :password       => "haiku575",
    :authentication => :login
  }

  config.facebook = {
    app_id: '90926621564',
    secret: '6045be51632c0658b3021c5653295ca1',
    user_class_name: 'Author'
  }
end

Sass::Plugin.options[:never_update] = true