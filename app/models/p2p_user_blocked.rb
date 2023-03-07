class P2pUserBlocked < ApplicationRecord
    belongs_to :p2p_user, class_name: "P2pUser", foreign_key: :p2p_user_id, primary_key: :id
    belongs_to :target_user, class_name: "P2pUser", foreign_key: :target_user_id, primary_key: :id

    extend Enumerize
    STATES = { unblocked: 100, blocked: -100 }
    enumerize :state, in: STATES, scope: true
end
