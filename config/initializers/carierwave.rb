# frozen_string_literal: true

require 'carrierwave/storage/abstract'
require 'carrierwave/storage/file'
require 'carrierwave/storage/fog'

CarrierWave.configure do |config|
    config.fog_credentials = {
      provider: 'Google',
      google_storage_access_key_id: 'GOOGIDJ5C7WKMIQHZV2AL3HQ',
      google_storage_secret_access_key: 'W6t2cdtAhe8/XosS4HrwkfWthUwNASGvLEB6Ebdt',
    }
    config.fog_directory = 'nusa-dev'
end