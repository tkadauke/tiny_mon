# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_tiny_mon_session',
  :secret      => '388f38a6fb218fe442c6ad357de934c242eca6af4fc947b013cb2018f1422d0bbd8f3bbe96f3c07cc61dfe7773af617f0d71a2b8d0724e580791f056a5ff9163'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
