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

    def positif_feedback
      feedback = ::P2pOrder.joins(:p2p_order_feedback, :p2p_offer).where(p2p_offers: {p2p_user_id: id}).where.not(p2p_orders: {state: 'prepare'})

      stats(feedback)
    end

    def trade
      trade = ::P2pOrder.joins(:p2p_offer)
              .where('(p2p_orders.p2p_user_id = ? AND p2p_orders.side = "buy")
                          OR
                      (p2p_offers.p2p_user_id = ? AND p2p_orders.side = "sell")', id, id)
      
      trade_stats(trade)
    end

    def trade_stats(data)
      state = 'completed'
      completed = data.count == 0 ? 0 : (data.where(state: state).count/data.count)*100

      {
        total: data.count,
        mount_trade: data.count,
        completed_rate: "#{}",
        release_time: "00:45:00",
        pay_time: "00:45:00"
      }
    end

    def stats(data)
      {
        total: data.count,
        positive: data.where(p2p_order_feedbacks: {assessment: 'positive'}).count,
        negative: data.where(p2p_order_feedbacks: {assessment: 'negative'}).count
      }
    end
end
