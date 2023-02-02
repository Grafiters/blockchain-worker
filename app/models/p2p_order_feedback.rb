class P2pOrderFeedback < ApplicationRecord
    belongs_to :p2p_user, dependent: :destroy
    belongs_to :p2p_order, class_name: 'P2pOrder', foreign_key: :order_number, primary_key: :order_number, dependent: :destroy
end
