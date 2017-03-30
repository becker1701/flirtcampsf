source 'https://rubygems.org'

ruby '2.3.1'

gem 'rails', '4.2.0'
gem 'pg', '0.17.1'
gem 'bootstrap-sass', '3.3.0'
gem 'will_paginate', '3.0.7'
gem 'bootstrap-will_paginate', '0.0.10'
gem 'sass-rails', '5.0.1'
gem 'uglifier', '2.5.3'
gem 'coffee-rails', '4.1.0'
gem 'jquery-rails', '4.0.3'
gem 'turbolinks', '2.3.0'
gem 'jbuilder', '2.2.3'
gem 'sdoc', '0.4.0', group: :doc

# Use ActiveModel has_secure_password
gem 'bcrypt', '~> 3.1.7'

gem 'faker', '1.4.2'
# Use Unicorn as the app server
# gem 'unicorn'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development
gem "letter_opener", group: :development
# gem "minitest-rails"
gem 'rack-mini-profiler'

group :development do
  gem 'meta_request'
end

group :development, :test do

  gem 'jazz_hands', github: 'jkrmr/jazz_hands'
  # Call 'byebug' anywhere in the code to stop execution and get a  console
  # gem 'byebug', '3.4.0'

  # Access an IRB console on exception pages or by using <%= console %> in views
  # gem 'web-console', '2.0.0'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring', '~> 1.3.3'
  gem 'terminal-notifier', '~> 1.6.2'
  gem 'terminal-notifier-guard', '~> 1.6.4'
  gem 'better_errors'
  gem 'binding_of_caller'

end

group :test do
  gem 'minitest-reporters', '~> 1.0.11'
  gem 'mini_backtrace'
  gem 'guard', '~>2.12.5'
  gem 'guard-minitest', '~>2.4.4'
  # gem "minitest-rails-capybara"
end

group :production do
  gem 'rails_12factor', '0.0.2'
  gem 'puma', '2.11.1'
end

gem 'simplecov', :require => false, :group => :test
