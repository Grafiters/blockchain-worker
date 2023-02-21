module API
    module V1
        module Market
            class Order < Grape::API
                helpers ::API::V1::Helpers
                helpers ::API::V1::Public::Helpers
                helpers ::API::V1::Admin::Helpers
                helpers ::API::V1::Market::NamedParams
                helpers ::API::V1::Market::RequestParams
                helpers ::API::V1::Market::OfferHelpers
                helpers ::API::V1::Market::OrderHelpers

                namespace :orders do
                    desc 'Create Order by P2p Offer'
                    params do
                        use :order
                    end
                    post '/' do
                        if p2p_user_auth.blank?
                            error!({ errors: ['p2p_user.user.account_p2p_doesnt_exists'] }, 422)
                        end

                        if current_user == receiver_p2p
                            error!({ errors: ['p2p_order.order.can_not_order_to_yourself'] }, 422)
                        end

                        offer = ::P2pOffer.find_by(offer_number: params[:offer_number])
                        if offer.blank?
                            error!({ errors: ['p2p_order.order.offer_number_does_not_exists'] }, 422)
                        end

                        otype = offer[:side] == 'sell' ? 'buy' : 'sell'
                        if offer[:side] == 'buy'
                            validation_request
                        end

                        orders = ::P2pOrder.create(p2p_order_params(offer, otype))
                        chat = ::P2pChat.create(chat_params(orders))
                        
                        present orders
                    end
                    # post '/' do
                    #     if p2p_user_auth.blank?
                    #         error!({ errors: ['p2p_user.user.account_p2p_doesnt_exists'] }, 422)
                    #     end

                    #     if current_user == receiver_p2p
                    #         error!({ errors: ['p2p_order.order.can_not_order_to_yourself'] }, 422)
                    #     end
                        
                    #     offer = ::P2pOffer.find_by(offer_number: params[:offer_number])
                    #     otype = offer[:side] == 'sell' ? 'buy' : 'sell'
                        
                    #     if otype == 'buy'
                    #         # present ::P2pOrder.submit_order(p2p_sell_params(offer, otype))
                    #         orders = create_order(p2p_sell_params(offer, otype))
                    #     else
                    #         # present ::P2pOrder.submit_order(p2p_buy_params(offer, otype))
                    #         orders = create_order(p2p_sell_params(offer, otype))
                    #     end

                    #     chat = ::P2pChat.create(chat_params(orders))

                    #     present orders
                    # end

                    desc 'Chat Order'
                    post '/information_chat/:order_number' do
                        order = ::P2pOrder.find_by(order_number: params[:order_number])
                        
                        chat = ::P2pChat.create(chat_params(order))
                        present chat
                    end

                    get '/information_chat/:order_number' do
                        order = ::P2pOrder.joins(:p2p_offer).find_by(order_number: params[:order_number])
                        room = ::P2pChat.joins(:p2p_order).select("p2p_chats.*","p2p_chats.user_uid as p2p_user").where(p2p_orders: { order_number: params[:order_number] })
                        room.each do |chat|
                            if chat[:user_uid] != 'Nusablocks'
                                chat[:p2p_user] = chat_user(chat[:user_uid])
                            end
                        end

                        if order[:p2p_user_id] == p2p_user_id[:id]
                            target = ::P2pUser.find_by(id: order[:p2p_user_id])
                        else
                            target = ::P2pUser.find_by(id: p2p_user_id[:id])
                        end

                        present :target, target, with: API::V1::Entities::UserP2p
                        present :room, room, with: API::V1::Entities::Chat
                    end

                    desc 'Detail P2p Order By Order Number'
                    get '/:order_number' do
                        order = ::P2pOrder.select("p2p_orders.*","p2p_orders.p2p_order_payment_id as payment").find_by(order_number: params[:order_number])

                        if order[:p2p_order_payment_id].present?
                            order_payment = ::P2pPaymentUser.joins(:p2p_order_payment, :p2p_payment).select("p2p_payments.*","p2p_order_payments.*","p2p_payment_users.name as account_name","p2p_payment_users.account_number", "p2p_payment_users.payment_user_uid").find_by(p2p_order_payments: {id: order[:p2p_order_payment_id]})
                            order[:payment] = order_payment
                        end

                        offer = ::P2pOffer.select("p2p_offers.*", "p2p_offers.created_at as payment","p2p_offers.updated_at as trader", "p2p_offers.p2p_pair_id as currency").find_by(id: order[:p2p_offer_id])
                        payment = ::P2pPaymentUser.joins(:p2p_order_payment, :p2p_payment)
                                                    .select("p2p_payments.*","p2p_order_payments.*","p2p_order_payments.id as p2p_payments")
                                                    .find_by(p2p_order_payments: {p2p_offer_id: offer[:id]})
                        
                        offer[:payment] = payment
                        offer[:currency] = currency(offer[:currency])[:currency].upcase

                        if offer[:side] == 'sell'
                            payment_merchant = ::P2pOrderPayment.joins(p2p_payment_user: :p2p_payment).select("p2p_order_payments.id","p2p_payment_users.payment_user_uid","p2p_payments.name as bank","p2p_payment_users.name as account_name","p2p_payment_users.name","p2p_payments.logo_url","p2p_payments.base_color","p2p_payment_users.account_number","p2p_payments.state").where(p2p_order_payments: {p2p_offer_id: offer[:id]})
                        end

                        present :order, order, with: API::V1::Entities::Order
                        present :offer, offer, with: API::V1::Market::Entities::Offer
                        if offer[:side] == 'sell'
                            present :payment_user, payment_merchant, with: API::V1::Entities::PaymentUser
                        end
                    end

                    desc 'Confirmation Target Payment final step'
                    put '/confirm/:order_number' do
                        order = ::P2pOrder.find_by(order_number: params[:order_number])
                        if order[:p2p_order_payment_id].blank?
                            error!({ errors: ['p2p_order.order.payment_confirm_not_exists'] }, 422)
                        end

                        if order[:state] == 'completed'
                            error!({ errors: ['p2p_order.order.already_completed_process'] }, 422)
                        end

                        if order[:state] == 'waiting' && p2p_user_id[:uid] == order[:taker_uid] || order[:state] == 'accepted' && p2p_user_id[:uid] == order[:maker_uid]
                            error!({ errors: ['p2p_order.order.can_not_confirm_by_your_self'] }, 422)
                        end

                        if order[:state] == 'waiting' && p2p_user_id[:uid] == order[:maker_uid]
                            state = 'accepted'
                            order.update({state: state, aproved_by: order[:maker_uid]})
                        elsif order[:state] == 'accepted'
                            state = 'success'
                            order.update({state: state, aproved_by: order[:maker_uid]})
                        end

                        { message: "Order Sucessfully Confirm by #{p2p_user_id[:uid]}" }

                    end
                    
                    desc 'Confirmation Target Payment step 1'
                    params do
                        requires :payment_method,
                                type: String,
                                desc: 'order.market.payment_method_invalid_value',
                                allow_blank: false
                    end
                    post '/payment_confirm/:order_number' do
                        order = ::P2pOrder.find_by(order_number: params[:order_number])
                        if order.blank?
                            error!({ errors: ['p2p_order.order.can_not_update_data_not_exists'] }, 422)
                        end

                        if order[:state] == 'completed'
                            error!({ errors: ['p2p_order.order.already_completed_process'] }, 422)
                        end

                        if order[:state] == 'canceled'
                            error!({ errors: ['p2p_order.order.process_has_canceled'] }, 422)
                        end

                        payment = ::P2pOrderPayment.joins(:p2p_payment_user, :p2p_offer).find_by(p2p_payment_users: {payment_user_uid: params[:payment_method]}, p2p_order_payments: {p2p_offer_id: order[:p2p_offer_id]})
                        if payment.blank?
                            error!({ errors: ['p2p_order.order.payment_user_not_found'] }, 422)
                        end

                        order.update({
                            p2p_order_payment_id: payment[:id],
                            first_approve_expire_at: Time.now,
                            second_approve_expire_at: Time.now + (24 * 60 * 60),
                            state: 'waiting'
                        })
                        present order
                    end

                    desc 'Cancel Order of Offer'
                    put '/cancel_order/:order_number' do
                        order = ::P2pOrder.find_by(order_number: params[:order_number])
                        if order[:state] == "success" || order[:state] == "completed"
                            error!({ errors: ['p2p_order.order.success_can_not_canceled_order'] }, 422)
                        end

                        order.update({state: "canceled", approved_by: current_user[:uid]})
                        present order
                    end

                    desc 'Report merchant when order progress'
                    params do
                        optional :image_payment
                        requires :order_number,
                                type: String,
                                desc: -> { V1::Entities::Order.documentation[:order_number] }
                        requires :reason_key
                        requires :message
                    end
                    post '/report/:order_number' do
                        order = ::P2pOrder.find_by(order_number: params[:order_number])

                        if params[:reason_key].blank?
                            error!({ errors: ['p2p_order.order.report.reason_can_not_blank'] }, 422)
                        end

                        report = ::P2pUserReport.create!(report_params)

                        params[:reason_key].each do |i, r|
                            if params[:message][i]['tempfile'].present?
                                ::P2pUserReportDetail.create!(report_image(report[:id], i))
                            else
                                ::P2pUserReportDetail.create!(report_detail(report[:id], i))
                            end
                        end

                        report = ::P2pUserReport.joins(:p2p_user_report_detail).find_by(p2p_user_reports: {order_number: params[:order_number]})

                        present report, with: API::V1::Entities::Report
                    end

                    desc 'Get Report By Order Number'
                    get '/report/:order_number' do
                        report = ::P2pUserReport.joins(:p2p_user_report_detail).where(p2p_user_reports: {order_number: params[:order_number]})

                        present report, with: API::V1::Entities::Report
                    end
                end
            end
        end
    end
end