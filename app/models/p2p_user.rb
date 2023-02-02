class P2pUser < ApplicationRecord
    has_many :p2p_payment_user, dependent: :destroy
    has_many :p2p_offer, dependent: :destroy
    has_many :p2p_order_feedback, dependent: :destroy

    belongs_to :member, dependent: :destroy
end
