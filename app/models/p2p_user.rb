class P2pUser < ApplicationRecord
    has_many :p2p_payment_user

    belongs_to :member
end
