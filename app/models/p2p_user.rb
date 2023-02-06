class P2pUser < ApplicationRecord
    has_many :p2p_payment_user, dependent: :destroy
    has_many :p2p_offer, dependent: :destroy
    has_many :p2p_order_feedback, dependent: :destroy

    belongs_to :member, dependent: :destroy

    class << self
        def from_payload(p)
            params = filter_payload(p)
            p2puser = P2pUser.find_or_create_by(member_id: p[:id]) do |m|
              m.member_id = params[:id]
            end
            p2puser.assign_attributes(params)
            p2puser.save! if p2puser.changed?
            p2puser
        end
      
          # Filter and validate payload params
        def filter_payload(payload)
            payload.slice(:id,)
        end
    end
end
