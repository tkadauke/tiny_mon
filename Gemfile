ruby '2.1.1'
source 'http://rubygems.org'
gem 'rails', '~> 4.0.3'
gem 'rake', '10.1.1'
gem "mysql2"

gem "acts_as_list"
gem "capybara"
gem "poltergeist", :require => 'capybara/poltergeist'
gem "orderedhash"
gem 'authlogic', '~> 3.3.0'
gem "background_lite", '0.3.2'
gem "will_paginate"
gem "permalink_fu"
gem 'rinku', :require => 'rails_rinku'
gem 'mail'
gem "dynamic_form"
gem "lhm", :require => false
gem "bootstrap-sass"
gem 'compass'
gem 'bootstrap-will_paginate'
gem 'scrypt'
gem 'rails-i18n', '~> 4.0.0'

gem 'jquery-rails'
gem 'jquery-ui-rails'
gem 'jqplot-rails', :git => 'git://github.com/eightbitraptor/jqplot-rails.git'

gem 'ionicons-rails'
gem 'font-awesome-rails'

group :assets do
  gem 'sass-rails', '~> 4.0.0'
  gem "therubyracer"
  gem "libv8"
  gem 'uglifier', '>= 1.0.3'
end

group :development do
  gem 'i18n_tools'
end

group :test do
  gem 'mocha'
end

group :production do
  gem "resque"
  gem "rails_12factor"
end

group :deploy do
  gem 'capistrano'
  gem 'capistrano-rvm'
  gem 'capistrano-bundler'
  gem 'capistrano-rails'
end

group :vm do
  gem 'vagrant', :git => 'git://github.com/mitchellh/vagrant.git', :ref => 'v1.2.2'
  gem 'vagrant-berkshelf', '>= 2.0.1'
end
