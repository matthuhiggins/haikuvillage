class FacebookConfig
  class << self
    def app_id
      config['app_id']
    end

    def secret
      config['secret']
    end

    def config
      @config ||= begin
        all_configs = YAML.load_file(Rails.root.join('config', 'facebook.yml'))
        all_configs[Rails.env] || {}
      end
    end
  end
end