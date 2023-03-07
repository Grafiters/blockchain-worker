class P2pOfferPayment < ApplicationRecord
    belongs_to :p2p_offer, foreign_key: :p2p_offer_id, primary_key: :id
    belongs_to :p2p_payment_user
end
