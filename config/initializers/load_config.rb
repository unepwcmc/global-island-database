APP_CONFIG = YAML.load(
  ERB.new(File.read("#{Rails.root}/config/config.yml")).result
)[Rails.env]

AUTH_CONFIG = YAML.load(
  ERB.new(File.read("#{Rails.root}/config/http_auth_config.yml")).result
)[Rails.env]

APP_CONFIG.merge!(AUTH_CONFIG)
