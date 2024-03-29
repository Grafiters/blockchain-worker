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
                side: offer[:side],
                taker_fee: fiat(offer)[:taker_fee],
                maker_fee: fiat(offer)[:maker_fee]
        end

        
        def create_order(offer)
          order = build_order(offer)
          order.submit_order
          order
        end

        def time_second_approve
		      ::P2pSetting.select("id, name, value").find_by(name: 'second_time_approve')
        end

        def order_payments(order)
            payment = ::P2pPaymentUser.joins(:p2p_payment).find_by(p2p_payment_users: {id: order[:p2p_payment_user_id]})
        end

        def validation_request
          offer = ::P2pOffer.find_by(offer_number: params[:offer_number])
          if offer[:state] == 'canceled'
            by_user = offer[:side] == 'buy' ? 'buyer' : 'seller'
            error!({ errors: ["p2p.order.this_offer_has_canceled_by_the_#{by_user}"] }, 422)
          end

          if params[:amount] < offer[:min_order_amount] || params[:amount] > offer[:max_order_amount]
            error!({ errors: ['p2p.order.price_order_not_available_for_offer'] }, 422)
          end

          if params[:amount] > offer[:available_amount]
            error!({ errors: ['p2p.order.price_order_not_available_for_offer'] }, 422)
          end

          if offer[:side] == 'buy'
            if params[:payment_order].blank?
              error!({ errors: ['p2p.order.payment_method_must_exists'] }, 422)
            end

            payment_user = ::P2pPaymentUser.find_by(payment_user_uid: params[:payment_order])

            payment = ::P2pOfferPayment.joins(:p2p_payment_user).
            find_by(p2p_offer_payments: {p2p_offer_id: offer[:id]}, p2p_payment_users: {p2p_payment_id: payment_user[:p2p_payment_id]})
            if payment.blank?
              error!({ errors: ['p2p.order.payment_method_not_avail_on_your_account'] }, 422)
            end
          end
        end
      end
    end
  end
end
