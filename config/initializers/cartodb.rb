CARTODB_CONFIG = YAML.load(
  ERB.new(
    File.read(Rails.root.join('config/cartodb_config.yml'))
  ).result
)

CartoDb.username = CARTODB_CONFIG['username']
CartoDb.api_key = CARTODB_CONFIG['api_key']
