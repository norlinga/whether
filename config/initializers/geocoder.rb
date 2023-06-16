# frozen_string_literal: true

# here we set a default configuration for Geocoder in an initializer.
# my choice in using Geocoder is demonstrated in SmartySearch and
# NominatimSearch - do the config and variable specification in the service,
# close to the point of usage, avoiding needless indirection
Geocoder.configure(
  cache: Redis.new,
  api_key: [ENV.fetch('SMARTY_AUTH_ID', nil), ENV.fetch('SMARTY_AUTH_TOKEN', nil)]
)
