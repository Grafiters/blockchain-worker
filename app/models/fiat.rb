class Fiat < ApplicationRecord
    serialize :data, JSON unless Rails.configuration.database_support_json

    has_many  :p2p_pair, foreign_key: :fiat, primary_key: :name
    has_many  :p2p_payment, foreign_key: :fiat_id, primary_key: :id

    extend Enumerize
    STATE = { true: 1, false: 0 }
    enumerize :state, in: STATE, scope: true

    scope :active, -> { where(state: true) }
end
