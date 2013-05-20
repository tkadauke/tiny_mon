source 'http://rubygems.org'

gem 'rails', '3.2.12'
gem "mysql2"

gem "acts_as_list"
gem "capybara"
gem "poltergeist", :require => 'capybara/poltergeist'
gem "orderedhash"
gem "authlogic"
gem "background_lite", '0.3.2'
gem "will_paginate"
gem "permalink_fu"
gem 'rinku', '~> 1.2.2', :require => 'rails_rinku'
gem 'tmail'
gem "dynamic_form"

gem "bootstrap-sass"
gem 'bootstrap-will_paginate'

# Deploy with Capistrano
gem 'capistrano'

gem 'jquery-rails'
gem 'jquery-ui-rails'
gem 'jqplot-rails', :git => 'git://github.com/eightbitraptor/jqplot-rails.git'

group :assets do
  gem 'sass-rails'
  gem "therubyracer", "0.10.2"
  gem "libv8", "3.3.10.2"
  gem 'uglifier', '>= 1.0.3'
end

group :development do
  gem 'i18n_tools'
end

group :test do
  gem "mocha", '0.9.8'
end

group :production do
  gem "resque"
end

group :vm do
  gem 'vagrant', :git => 'git://github.com/mitchellh/vagrant.git', :ref => 'v1.2.2'
  gem 'berkshelf'
  gem 'vagrant-berkshelf'
end
