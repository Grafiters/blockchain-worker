class P2pPayment < ApplicationRecord
    belongs_to :fiat, foreign_key: :fiat_id
end
