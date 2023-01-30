class P2pPaymentUser < ApplicationRecord
    has_many :p2p_order_payment, dependent: :destroy
    
    belongs_to :p2p_users
    belongs_to :p2p_payment
end
