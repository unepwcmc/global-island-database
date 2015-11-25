source 'https://rubygems.org'

gem 'rails', '3.2.22'

gem 'pg', '~> 0.18.4'
gem 'bootstrap-generators', '~> 2.0', :git => 'git://github.com/decioferreira/bootstrap-generators.git'
gem 'simple_form'
gem 'underscore-rails', '~> 1.8.3'
gem 'RedCloth'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'

  gem 'uglifier', '~> 2.7.2'
end

group :production, :staging do
  gem 'exception_notification', '~> 4.1.1'
  gem 'slack-notifier', '~> 1.4.0'
end

gem 'jquery-rails', '~> 3.1.3'
gem 'rails-backbone', '~> 1.2.0'
gem 'devise', '~> 3.5.2'

gem 'sidekiq', '~> 4.0.1'

# Deploy with Capistrano
gem 'rvm-capistrano'
gem 'capistrano'
gem 'brightbox'
gem 'capistrano-ext'

group :development, :test do
  # To use debugger
  gem 'database_cleaner'

  gem 'guard'
  gem 'guard-rspec', require: false
  gem 'rb-fsevent', '~> 0.9'
end

gem 'rake', '0.9.2'

gem 'rspec-rails', '~> 2.6', :group => [:development, :test]
gem 'test-unit', '~> 3.1.5'

gem 'dotenv', '~> 2.0.2'
gem 'httparty', '~> 0.13.7'
gem 'newrelic_rpm', '~> 3.14.0.305'

