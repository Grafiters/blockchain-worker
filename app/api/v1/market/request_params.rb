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
                            type: {value: String, message: 'offer.market.payment_invalid_value'}
                end

                params :chats do
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

                def p2p_order_params(offer, side)
                    params_mapping = {
                        p2p_offer_id: offer[:id],
                        p2p_user_id: p2p_user_id[:id],
                        maker_uid: current_user[:uid],
                        taker_uid: receiver_p2p[:uid],
                        amount: params[:amount],
                        side: side,
                        p2p_order_payment_id: side == 'sell' ? payment(offer)[:id] : nil
                    }
                end

                def chat_params(order, target_user)
                    params_mapping = {
                        p2p_order_id: order[:id],
                        user_uid: target_user.present? ? targer_offer_uid(order) : current_user[:uid],
                        chat: params[:message].present? ? image_check : 'Mohon Kirim Bukti tranfer',
                        upload: params[:message].present? ? image_exists : nil
                    }
                end

                def targer_offer_uid(order)
                    if order[:side] == 'sell'
                        order[:taker_uid]
                    else
                        order[:maker_uid]
                    end
                end

                def payment(offer)
                    payment_user = ::P2pPaymentUser.find_by(payment_user_uid: params[:payment_order])
                end

                def image_check
                    params[:message]['tempfile'].blank? ? params[:message] : nil
                end

                def image_exists
                    params[:message]['tempfile'].present? ? params[:message]['tempfile'] : nil
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

                def report_params
                    {
                        p2p_user_id: p2p_user_id[:id],
                        order_number: params[:order_number]
                    }
                end

                def report_detail(report_id, data)
                    {
                        p2p_user_report_id: report_id,
                        key: data[:key],
                        reason: data[:message].present? ? data[:message] : nil,
                        upload: data[:upload_payment].present? ? data[:upload_payment]['tempfile'] : nil
                    }
                end

                def chat_user(uid)
                    ::P2pUser.joins(:member).select("p2p_users.*","members.uid as uid","members.email").find_by(members: {uid: uid})
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