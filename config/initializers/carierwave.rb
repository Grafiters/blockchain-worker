# # frozen_string_literal: true

require 'carrierwave/storage/abstract'
require 'carrierwave'
require 'carrierwave/storage/file'
# require 'carrierwave/storage/fog'

CarrierWave.configure do |config|
    config.storage = :file
    config.permissions = 0666
    config.directory_permissions = 0777
    config.store_dir = "uploads/images/"
end