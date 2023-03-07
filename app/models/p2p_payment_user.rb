class P2pPaymentUser < ApplicationRecord
    mount_uploader :qrcode, PaymentUserUploader

    has_many :p2p_offer_payment, dependent: :destroy
    
    extend Enumerize
    STATES = { active: 0, inactive: -100, deleted: -200 }
    enumerize :state, in: STATES, scope: true

    belongs_to :p2p_users
    belongs_to :p2p_payment

    before_create :assign_uuid

    def verification_url
        "/api/v2/p2p/confirmation_chat/#{id}"
    end
    
    private
    def assign_uuid
        return unless payment_user_uid.blank?

        self.payment_user_uid = InterIDGenerate('P4Y')
    end

    def InterIDGenerate(prefix)
        loop do
          uid = "%s%s" % [prefix.upcase, SecureRandom.hex(5).upcase]
          return uid if P2pPaymentUser.where(payment_user_uid: uid).empty?
        end
    end
end