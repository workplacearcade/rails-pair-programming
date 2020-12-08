source 'https://rubygems.org'
ruby '2.6.2'

# Load environment variables
gem "dotenv-rails"

gem 'rake', '13.0.1'
gem 'rails', '5.2.3'

gem 'pg', '1.2.3'

gem 'listen'

# Bulk imports
gem 'activerecord-import'

# For rendering JSON
gem 'active_model_serializers', '0.9.5', require: true

# Composite primary keys in join tables
# gem 'composite_primary_keys', '~> 8.1.0'

# Authentication
gem 'devise', '4.7.1'
gem 'jwt'
gem 'rack-cors'
# gem 'omniauth-azure-activedirectory', git: 'git@github.com:workplacearcade/omniauth-azure-activedirectory.git'

# Simple YAML configuration/settings
gem 'settingslogic'

# Modeling hierarchical data
gem 'closure_tree'

# Query AR objects based on time
gem 'by_star'

# To continue using respond_to
gem 'responders'

# Providing schema validation for application settings
gem 'dry-schema'

# Making #blank? calls faster
gem 'fast_blank'

# Timezone data no longer installed by default
gem 'tzinfo-data'
gem "unicorn"
gem 'awesome_print'

# HTTP client wrapper
gem 'faraday'
gem 'faraday_middleware'

group :development, :test do
  gem 'pry'
  gem 'pry-rails'
  gem 'pry-rescue'
  gem 'pry-stack_explorer'
  gem 'pry-byebug'
  gem 'rspec-rails', '~> 3.7', :require => false
  gem 'factory_bot_rails'
  gem 'database_cleaner'
  gem 'yajl-ruby'
  gem 'capybara-json'
  gem 'saharspec', :require => false
  gem 'timecop'
  gem 'email_spec'
  gem 'letter_opener'
  gem 'parallel_tests'
  gem 'spring'
  # Ensure these are installed on CI
  gem 'capistrano', '~> 3.14', require: false
  gem 'capistrano-rails', '~> 1.6', require: false

  gem 'rubocop', '~> 0.79.0', require: false
  gem 'pact'

  gem 'bullet'
end
