HaikuVillage::Application.configure do
  config.cache_classes = true
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true
  config.serve_static_assets = false
  config.assets.compress = true
  config.assets.compile = true
  config.assets.digest = true
  config.action_dispatch.x_sendfile_header = nil

  config.facebook = {
    app_id: '110364292360364',
    secret: '120742aa5354718c03b7f73209df36ed',
    user_class_name: 'Author'
  }
end