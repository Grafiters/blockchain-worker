class P2pOffer < ApplicationRecord
    serialize :data, JSON unless Rails.configuration.database_support_json

    has_many :p2p_order_payment

    belongs_to :p2p_pair, dependent: :destroy
    belongs_to :p2p_user, dependent: :destroy

    before_validation :assign_uuid
    
    after_commit om: :create do
      update_account_offer
    end

    private
    def update_account_offer
      self.increment!(:offers_count)
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
