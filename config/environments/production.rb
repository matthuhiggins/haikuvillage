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
end