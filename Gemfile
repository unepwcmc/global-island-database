source 'https://rubygems.org'

gem 'rails', '3.2.13'

gem 'pg'
gem 'bootstrap-generators', '~> 2.0', :git => 'git://github.com/decioferreira/bootstrap-generators.git'
gem 'simple_form'
gem 'underscore-rails'
gem 'cartodb-rb-client', :git => "https://github.com/Vizzuality/cartodb-rb-client.git"
gem 'RedCloth'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  gem 'therubyracer'

  gem 'uglifier', '>= 1.0.3'
end

gem 'jquery-rails'
gem 'rails-backbone'
gem 'devise'

#Handle background jobs
gem 'resque'

# Deploy with Capistrano
gem 'rvm-capistrano'
gem 'capistrano'
gem 'brightbox'
gem 'capistrano-ext'

group :development, :test do
  # To use debugger
  gem 'ruby-debug19'#, :require => 'ruby-debug'
  gem 'database_cleaner'

  gem 'guard'
  gem 'guard-rspec', require: false
  gem 'rb-fsevent', '~> 0.9'
end

gem 'rake', '0.9.2'

gem 'json', '1.5.3'

gem 'rspec-rails', '~> 2.6', :group => [:development, :test]
