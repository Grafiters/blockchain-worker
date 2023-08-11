class Setting < ApplicationRecord
    serialize :data, JSON unless Rails.configuration.database_support_json

    validates :name, presence: true, uniqueness: true
    validates :value, :description, :deleted, presence: true

    extend Enumerize
    STATES = { false: 0, true: 1 }
    enumerize :deleted, in: STATES, scope: true

    class << self
        def contains_space?(text)
            !!(/^[a-zA-Z0-9_]+$/ =~ text)
        end
    end
end
