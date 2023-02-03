class P2pChat < ApplicationRecord
    belongs_to :p2p_order, dependent: :destroy
end
