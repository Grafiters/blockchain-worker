# frozen_string_literal: true

module API
  module V1
    module Market
      module OrderHelpers
        def build_order(offer)
            ::P2pOrder.new \
                p2p_offer_id: offer[:p2p_offer_id],
                p2p_user_id: offer[:p2p_user_id],
                maker_uid: offer[:maker_uid],
                taker_uid: offer[:taker_uid],
                amount: offer[:amount],
                side: offer[:side]
        end

        def create_order(offer)
          order = build_order(offer)
          order.submit_order
          order
        end
      end
    end
  end
end
