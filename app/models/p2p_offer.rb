class P2pOffer < ApplicationRecord
    serialize :data, JSON unless Rails.configuration.database_support_json

    belongs_to :p2p_pair
end
