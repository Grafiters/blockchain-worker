module API
    module V1
        module Market
            class Order < Grape::API
                helpers ::API::V1::Admin::Helpers
                helpers ::API::V1::Market::RequestParams
                namespace :orders do
                    desc 'Create Order P2p'
                    post '/' do
                        if current_user == receiver_p2p
                            error!({ errors: ['p2p_order.order.can_not_order_to_yourself'] }, 422)
                        end
                        
                        offer = ::P2pOffer.find_by(offer_number: params[:offer_number])
                        otype = offer[:side] == 'sell' ? 'buy' : 'sell'
                        
                        if otype == 'buy'
                            orders = ::P2pOrder.create(p2p_sell_params(offer, otype))
                        else
                            orders = ::P2pOrder.create(p2p_buy_params(offer, otype))
                        end

                        present orders
                    end

                    desc 'Detail P2p Order By Order Number'
                    get '/:order_number' do
                        order = ::P2pOrder.select("p2p_orders.*","p2p_orders.p2p_order_payment_id as payment").find_by(order_number: params[:order_number])

                        if order[:p2p_order_payment_id].present?
                            order_payment = ::P2pPaymentUser.joins(:p2p_order_payment, :p2p_payment).select("p2p_payments.*","p2p_order_payments.*").find_by(p2p_order_payments: {id: order[:p2p_order_payment_id]})
                            order[:payment] = order_payment
                        end

                        offer = ::P2pOffer.select("p2p_offers.*", "p2p_offers.created_at as payment","p2p_offers.updated_at as trader").find_by(id: order[:p2p_offer_id])
                        payment = ::P2pPaymentUser.joins(:p2p_order_payment, :p2p_payment)
                                                    .select("p2p_payments.*","p2p_order_payments.*","p2p_order_payments.id as p2p_payments")
                                                    .where(p2p_order_payments: {p2p_offer_id: offer[:id]})
                                                    .where(p2p_order_payments: {state: "active"})
                        
                        offer[:payment] = payment
                        offer[:trader]  = ::Member.find_by(uid: order[:uid])

                        present :order, order, with: API::V1::Entities::Order
                        present :offer, offer, with: API::V1::Entities::Offer
                    end

                    desc 'Confirmation Target Payment step 1'
                    put '/confirm/:order_number' do
                        order = ::P2pOrder.find_by(order_number: params[:order_number])
                        if order.state != "waiting"
                            error!({ errors: ['p2p_order.order.payment_confirm_not_exists'] }, 422)
                        end

                        state = order[:side] == 'sell' ? 'completed' : 'success'

                        order.update({state: state, aproved_by: order[:maker_uid], second_approve_expire_at: Time.now})

                        present order
                    end

                    put '/payment_confirm/:order_number' do
                        order = ::P2pOrder.find_by(order_number: params[:order_number])
                        order.update({state: "completed", p2p_order_payment_id: params[:payment_method], first_approve_expire_at: Time.now})
                        present order
                    end

                    put '/cancel_order/:order_number' do
                        order = ::P2pOrder.find_by(order_number: params[:order_number])
                        if order[:state] == "completed" || order[:state] == "success"
                            error!({ errors: ['p2p_order.order.success_can_not_canceled_order'] }, 422)
                        end

                        order.update(state: "canceled")
                        present order
                    end
                end
            end
        end
    end
end