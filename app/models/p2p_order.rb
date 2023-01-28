class P2pOrder < ApplicationRecord
    has_many :p2p_order_payment, dependent: :destroy

end
