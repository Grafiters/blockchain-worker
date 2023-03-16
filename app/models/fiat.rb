class Fiat < ApplicationRecord
    serialize :data, JSON unless Rails.configuration.database_support_json

    has_many  :p2p_pair, foreign_key: :fiat, primary_key: :name
    has_many  :p2p_payment, foreign_key: :fiat_id, primary_key: :id

    scope :active, -> { where(status: %i[enabled hidden]) }
end
