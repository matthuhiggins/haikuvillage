HaikuVillage::Application.configure do
  config.cache_classes = false
  config.whiny_nils = true
  config.consider_all_requests_local = true

  config.action_controller.perform_caching             = false

  config.action_mailer.raise_delivery_errors = false
  config.action_mailer.delivery_method = :test
  
  config.facebook = {
    app_id: '147267751983310',
    secret: 'e36a59a343c00bb05026e897e08bc8ac',
    user_class_name: 'Author'
  }
end