class P2pUser < ApplicationRecord
    has_many :p2p_payment_user, dependent: :destroy
    has_many :p2p_offer, dependent: :destroy
    has_many :p2p_order_feedback, dependent: :destroy
    has_many :p2p_blocked

    belongs_to :member, class_name: "Member", foreign_key: :member_id, primary_key: :id

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
            payload.slice(:id)
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
        mount_trade: data.where("p2p_orders.created_at >= ? AND p2p_orders.created_at <= ?", last_month, Time.now).count,
        completed_rate: data.where("p2p_orders.state IN (?)", %w(success accepted)).where("p2p_orders.created_at >= ? AND p2p_orders.created_at <= ?", last_month, Time.now).count,
        release_time: release_time(data, data.count),
        pay_time: pay_time(data, data.count)
      }
    end


    def pay_time(data, total)
      time = data.where("p2p_orders.state IN (?)", %w(success accepted)).where("p2p_orders.created_at >= ? AND p2p_orders.created_at <= ?", last_month, Time.now)
      return "000000" unless time.present?
      sum_time = 0
      time.each do |t|
        sum_time += t[:first_approve_expire_at] - t[:created_at]
      end

      return sum_time
    end

    def release_time(data, total)
      time = data.where("p2p_orders.state IN (?)", %w(success accepted)).where("p2p_orders.created_at >= ? AND p2p_orders.created_at <= ?", last_month, Time.now)
      return "000000" unless time.present?
      sum_time = 0
      time.each do |t|
        sum_time += t[:second_approve_expire_at] - t[:first_approve_expire_at]
      end

      return sum_time
    end

    def last_month
      now = Date.today

      ninety_days_ago = (now - 30)
    end

    def stats(data)
      {
        total: data.count,
        positive: data.where(p2p_order_feedbacks: {assessment: 'positive'}).count,
        negative: data.where(p2p_order_feedbacks: {assessment: 'negative'}).count
      }
    end
end
