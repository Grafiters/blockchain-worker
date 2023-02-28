class P2pOrderFeedback < ApplicationRecord
    belongs_to :p2p_user, class_name: "P2pUser", foreign_key: :p2p_user_id, primary_key: :id
    belongs_to :p2p_order, class_name: 'P2pOrder', foreign_key: :order_number, primary_key: :order_number, dependent: :destroy
end
