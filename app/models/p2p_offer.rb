class P2pOffer < ApplicationRecord
    serialize :data, JSON unless Rails.configuration.database_support_json

    has_many :p2p_order_payment

    belongs_to :p2p_pair, dependent: :destroy
    belongs_to :p2p_user, dependent: :destroy

    before_validation :assign_uuid

    # def submit_offer
    #     return unless new_record?

    #     self.locked = self.origin_locked = if ord_type == 'market' && side == 'buy'
    #                                         [compute_locked * OrderBid::LOCKING_BUFFER_FACTOR, member_balance].min
    #                                     else
    #                                         compute_locked
    #                                     end

    #     raise ::Account::AccountError unless member_balance >= locked

    #     return trigger_third_party_creation unless market.engine.peatio_engine?

    #     save!
    #     AMQP::Queue.enqueue(:order_processor,
    #                         { action: 'submit', order: attributes },
    #                         { persistent: false })
    # end

    private
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
