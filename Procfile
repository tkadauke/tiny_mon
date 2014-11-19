#!/bin/bash
#web: bundle exec rails server -p $PORT
worker: bundle exec rake scheduler:start
web:  bundle exec puma -C config/puma.rb
