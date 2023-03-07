class P2pChat < ApplicationRecord
    mount_uploader :upload, UploaderUploader

    belongs_to :p2p_order, dependent: :destroy

    def verification_url
        "/api/v2/p2p/market/orders/information_chat/#{id}"
    end
end
