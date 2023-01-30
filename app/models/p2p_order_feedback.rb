class P2pOrderFeedback < ApplicationRecord
    belongs_to :p2p_order, dependent: :destroy
end
