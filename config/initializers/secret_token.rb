# Be sure to restart your server when you modify this file.

# Your secret key for verifying the integrity of signed cookies.
# If you change this key, all old signed cookies will become invalid!

# Make sure the secret is at least 30 characters and all random,
# no regular words or you'll be exposed to dictionary attacks.
# You can use `rake secret` to generate a secure secret key.

# Make sure your secret_key_base is kept private
# if you're sharing your code publicly.

# Although this is not needed for an api-only application, rails4 
# requires secret_key_base or secret_token to be defined, otherwise an 
# error is raised.
# Using secret_token for rails3 compatibility. Change to secret_key_base
# to avoid deprecation warning.
# Can be safely removed in a rails3 api-only application.
Rails.application.config.secret_token = ENV['SECRET_TOKEN'] || '07d5d791a634435f80e0fb1e4b4faea4d16a9c928181de6f0759380c886a2ca4b0ad367b6a0f7b8924ab0e779135bbfc63f7851b9f288e2f1e1a8d233c5bb0e7'

