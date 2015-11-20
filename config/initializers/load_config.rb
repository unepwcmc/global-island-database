APP_CONFIG = YAML.load_file(
  "#{Rails.root}/config/config.yml"
)[Rails.env]

AUTH_CONFIG = YAML.load(
  ERB.new(File.read("#{Rails.root}/config/http_auth_config.yml")).result
)[Rails.env]

APP_CONFIG.merge!(AUTH_CONFIG)
