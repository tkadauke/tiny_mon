#!/bin/bash
web: bundle exec rails server -p $PORT
worker: cd /app && bundle exec rake scheduler:start