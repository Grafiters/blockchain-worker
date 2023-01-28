class P2pOrderPayment < ApplicationRecord
    belongs_to :p2p_offer
    belongs_to :p2p_payment_user
end
