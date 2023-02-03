# encoding: UTF-8
# frozen_string_literal: true

module API
    module V1
        module Market
            module RequestParams
                extend ::Grape::API::Helpers
                
                params :order do
                    requires :offer_number,
                            type: String,
                            desc: -> { V1::Entities::Offer.documentation[:offer_number] }
                    requires :price,
                            type: { value: BigDecimal, message: 'offer.order.non_decimal_price' },
                            values: { value: -> (p){ p.try(:positive?) }, message: 'offer.order.non_positive_price' }
                    requires :amount,
                            type: { value: BigDecimal, message: 'offer.order.non_decimal_price' },
                            values: { value: -> (p){ p.try(:positive?) }, message: 'offer.order.non_positive_price' }
                    optional :payment_order,
                            type: {value: Integer, message: 'offer.market.payment_invalid_value'}
                end

                params :chat do
                    requires :offer_number,
                            type: String,
                            desc: -> { V1::Entities::Offer.documentation[:offer_number] }
                    requires :message,
                            type: {value: String, message: 'order.market.chat_must_be_exists'}
                end

                def build_params
                    params_mapping = {
                        p2p_user_id: p2p_user_id[:id],
                        p2p_pair_id: p2p_pairs[:id],
                        available_amount: params[:trade_amount],
                        price: params[:price],
                        min_order_amount: params[:min_order],
                        max_order_amount: params[:max_order],
                        side: params[:side],
                        paymen_limit_time: params[:payment_limit],
                        term_of_condition: params[:term_of_condition],
                        auto_replay: params[:auto_replay]
                    }
                end

                def payment_params(ofid, data)
                    paymen = {
                        p2p_offer_id: ofid,
                        p2p_payment_user_id: data,
                        state: 'active'
                    }
                end

                def p2p_sell_params(offer, side)
                    params_mapping = {
                        p2p_offer_id: offer[:id],
                        p2p_user_id: p2p_user_id[:id],
                        maker_uid: current_user[:uid],
                        taker_uid: receiver_p2p[:uid],
                        amount: params[:amount],
                        side: side
                    }
                end

                def p2p_buy_params(offer, side)
                    params_mapping = {
                        p2p_offer_id: offer[:id],
                        p2p_user_id: p2p_user_id[:id],
                        maker_uid: current_user[:uid],
                        taker_uid: receiver_p2p[:uid],
                        amount: params[:amount],
                        state: 'waiting',
                        first_approve_expire_at: Time.now,
                        side: side,
                        p2p_order_payment_id: params[:payment_order]
                    }
                end

                def chat_params(order)
                    params_mapping = {
                        p2p_order_id: order[:id],
                        p2p_user_id: p2p_user_id[:uid],
                        chat: params[:message].present? ? params[:message] : 'Mohon Kirim Bukti tranfer'
                    }
                end

                def receiver_p2p
                    offer = P2pOffer.find_by(offer_number: params[:offer_number])
                    ::Member.joins(:p2p_user)
                            .select("members.*")
                            .find_by(p2p_users: {id: offer[:p2p_user_id]})
                end

                def feedback_params
                    params_mapping = {
                        p2p_user_id: p2p_user_id[:id],
                        order_number: params[:order_number],
                        comment: params[:comment],
                        assessment: params[:assesment]
                    }
                end

                def p2p_user_id
                    ::P2pUser.joins(:member).select("p2p_users.*","members.uid as uid").find_by(members: {uid: current_user.uid})
                end

                private                

                def p2p_pairs
                    ::P2pPair.find_by({fiat: params[:fiat], currency: params[:currency]})
                end
            end
        end
    end
end