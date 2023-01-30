class P2pPayment < ApplicationRecord
    has_many :p2p_payment_user, dependent: :destroy

    belongs_to :fiat, foreign_key: :fiat_id
end
