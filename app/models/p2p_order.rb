class P2pOrder < ApplicationRecord
    has_many :p2p_order_payment, dependent: :destroy
    has_many :p2p_order_feedback, class_name: 'P2pOrderFeedback', foreign_key: :order_number, primary_key: :order_number

    belongs_to :p2p_offer, required: true

    # def update_offer()

    before_create :assign_order_number


    private

    def assign_order_number
        assign_order_number unless order_number.blank?

        self.order_number = InterIDGenerate('P2PORD')
    end

    def InterIDGenerate(prefix)
        loop do
          uid = "%s%s" % [prefix.upcase, SecureRandom.hex(5).upcase]
          return uid if P2pOrder.where(order_number: uid).empty?
        end
    end
end
