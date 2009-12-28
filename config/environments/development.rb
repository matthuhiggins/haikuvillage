config.cache_classes = false

config.whiny_nils = true

config.action_controller.consider_all_requests_local = true
config.action_controller.perform_caching             = false

config.action_view.debug_rjs                         = true

config.action_mailer.raise_delivery_errors = true
config.action_mailer.smtp_settings = {
  :address  => "mail.spiz.us",
  :port  => 587, 
  :domain  => "haikuvillage.com",
  :user_name  => "village",
  :password  => "haiku575",
  :authentication  => :login
}
# config.action_mailer.delivery_method       = :test