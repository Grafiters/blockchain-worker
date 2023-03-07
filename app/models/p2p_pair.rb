class P2pPair < ApplicationRecord
    serialize :data, JSON unless Rails.configuration.database_support_json

    has_many :p2p_offer
end
