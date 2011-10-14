HaikuVillage::Application.configure do
  config.cache_classes = true
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true
  config.serve_static_assets = false
  config.assets.compress = true
  config.assets.compile = true
  config.assets.digest = true
  config.action_dispatch.x_sendfile_header = nil
  config.action_mailer.delivery_method = :smtp
  ActionMailer::Base.smtp_settings = {
    :address        => 'smtp.sendgrid.net',
    :port           => '587',
    :authentication => :plain,
    :user_name      => ENV['SENDGRID_USERNAME'],
    :password       => ENV['SENDGRID_PASSWORD'],
    :domain         => 'heroku.com'
  }

  config.facebook = {
    app_id: '110364292360364',
    secret: '120742aa5354718c03b7f73209df36ed',
    user_class_name: 'Author'
  }
end