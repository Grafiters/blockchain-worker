class Setting < ApplicationRecord
    serialize :data, JSON unless Rails.configuration.database_support_json

    validates :name, presence: true, :unique => true
    validates :value, :description, :deleted, presence: true

    class << self
        def contains_space?(text)
            !!(/^[a-zA-Z0-9_]+$/ =~ text)
        end
    end
end
