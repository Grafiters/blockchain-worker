class P2pOffer < ApplicationRecord
    serialize :data, JSON unless Rails.configuration.database_support_json

    has_many :p2p_offer_payment

    belongs_to :p2p_pair, dependent: :destroy
    belongs_to :p2p_user, dependent: :destroy

    before_validation :assign_uuid
    
    after_commit on: :create do
      update_account_offer
    end

    def payment
      ::P2pOrderPayment.joins(p2p_payment_user: :p2p_payment)
                                                    .select("p2p_payments.*","p2p_offer_payments.*","p2p_offer_payments.id as p2p_payments")
                                                    .where(p2p_offer_payments: {p2p_offer_id: id})
    end

    def sold
      order = ::P2pOrder.joins(:p2p_offer).where(p2p_offer_id: id)

      {
        sold: sold_query(order).sum(:amount),
        bought: bought_query(order).sum(:amount)
      }
    end

    def sold_query(base)
      base.where("p2p_offers.side = 'sell' AND p2p_orders.state IN (?)", %w(accepted, success))
    end

    def bought_query(base)
      base.where("p2p_offers.side = 'buy' AND p2p_orders.state IN (?)", %w(accepted, success))
    end

    def fiat_logo
      ::Fiat.select("name", "icon_url").find_by(name: fiat)
    end

    def currency_logo
        ::Currency.select("id as name", "icon_url").find_by(id: currency)
    end

    private
    def update_account_offer
      offer = ::P2pUser.find_by(id: p2p_user_id)
      offer.increment!(:offers_count)
    end

    def assign_uuid
        return unless offer_number.blank?

        self.offer_number = InterIDGenerate('OFF')
    end

    def InterIDGenerate(prefix = 'OF')
        loop do
          uid = "%s%s" % [prefix.upcase, SecureRandom.hex(5).upcase]
          return uid if P2pOffer.where(offer_number: uid).empty?
        end
      end
end
