class P2pPaymentUser < ApplicationRecord
    # mount_uploader :qrcode, PaymentUserUploader

    has_many :p2p_order_payment, dependent: :destroy
    
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
