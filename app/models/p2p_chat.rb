class P2pChat < ApplicationRecord
    mount_uploader :upload, UploaderUploader

    belongs_to :p2p_order, dependent: :destroy
    belongs_to :member, class_name: 'Member', foreign_key: :user_uid, primary_key: :uid, dependent: :destroy

    def verification_url
        "/api/v2/p2p/market/orders/information_chat/#{id}"
    end
end
