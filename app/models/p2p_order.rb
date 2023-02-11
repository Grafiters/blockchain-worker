class P2pOrder < ApplicationRecord
    has_many :p2p_order_payment, dependent: :destroy
    has_many :p2p_order_feedback, class_name: 'P2pOrderFeedback', foreign_key: :order_number, primary_key: :order_number
    has_many :p2p_chat, dependent: :destroy

    belongs_to :p2p_offer, foreign_key: :p2p_offer_id, primary_key: :id
    before_create :assign_order_number, :first_expired_time

    validates :side, :amount, presence: true

    class << self
        def submit(id)
            ActiveRecord::Base.transaction do
                order = self.find_by_id!(id)
                Rails.logger.warn order

                if Time.now >= order[:first_approve_expire_at]
                    order.update(state: 'waiting')
                end
                # Rails.logger.warn id
                # AMQP::Queue.enqueue(:p2p_order_processor, action: 'submit', order: order)
            end
        end

        def cancel(id)
            ActiveRecord::Base.transaction do
              order = self.find_by_id!(id)
              return unless order.state != 'success'
      
              order.update!(state: 'canceled')
            end
        end
    end
    
    def trades
        if side == 'sell'
            member = Member.joins(:p2p_user).select("members.uid","p2p_users.username","members.email").find_by(members: {uid: maker_uid})
        elsif side == 'buy'
            member = Member.joins(:p2p_user).select("members.uid","p2p_users.username","members.email").find_by(members: {uid: taker_uid})
        end

        as_json_trade(member)
    end

    def fiat_logo
        ::Fiat.select("name", "icon_url").find_by(name: fiat)
    end

    def fiat_amounts
        BigDecimal(price) * BigDecimal(amount)
    end

    def as_json_trade(data)
        {
            uid: data[:uid],
            username: data[:username],
            email: email_data_masking(data[:email])
        }
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
        completed_rate = data.count == 0 ? 0 : (data.where(state: state).count/data.count)*100
        {
          total: data.count,
          mount_trade: data.count,
          completed_rate: "#{completed_rate}",
        }
      end

    def submit_order
        return unless new_record?

        save!
        AMQP::Queue.enqueue(
            :p2p_order_processor,
            {action: 'submit', order: attributes},
            {persistent: false}
        )
    end

    def email_data_masking(email)
        if email.present?
          email.downcase.sub(/(?<=[\w\d])[\w\d]+(?=[\w\d])/, '*****')
        else
          email
        end
    end

    def as_json_for_events_processor
        { 
            id:            id,
            p2p_offer_id:  p2p_offer_id,
            p2p_user_id:   p2p_user_id,
            maker_uid:     maker_uid,
            taker_uid:     taker_uid,
            amount:        amount,
            side:          side
        }
    end

    def amount_order
        offer = ::P2pOffer.find_by(id: p2p_offer_id)
        
        amount * offer.price
    end


    def first_count_down_time
        if state == 'canceled'
            return 'xx:xx:xx'
        end
        if state == 'prepare'
            time = (self.first_approve_expire_at.to_i - self.created_at.to_i)
        elsif state == 'waiting'
            offer = ::P2pOffer.find_by(id: p2p_offer_id)
            time = offer.paymen_limit_time * 60
        end

        Time.at(time).gmtime.strftime('%R:%S')
    end

    private

    def assign_order_number
        assign_order_number unless order_number.blank?

        self.order_number = InterIDGenerate('P2PORD')
    end

    def first_expired_time
        self.first_approve_expire_at = Time.now + 15*60
    end

    def second_expire_at
        self.second_approve_expire_at = Time.now + 15*60
    end

    def InterIDGenerate(prefix)
        loop do
          uid = "%s%s" % [prefix.upcase, SecureRandom.hex(5).upcase]
          return uid if P2pOrder.where(order_number: uid).empty?
        end
    end
end
