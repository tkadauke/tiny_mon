#!/bin/bash
web: bundle exec puma -C config/puma.rb
#worker: bundle exec rake db:migrate
worker: bundle exec rake scheduler:start
