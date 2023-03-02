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
                        validation_request

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

                        orders = ::P2pOrder.create(p2p_order_params(offer, otype))
                        chat = ::P2pChat.create(chat_params(orders, orders[:taker_uid]))
                        
                        present orders
                    end

                    desc 'Chat Order'
                    params do
                        requires :message
                    end
                    post '/information_chat/:order_number' do
                        order = ::P2pOrder.find_by(order_number: params[:order_number])

                        if params[:message].blank?
                            error!({ errors: ['p2p_order.information_chat.message_can_not_blank'] }, 422)
                        end

                        if order[:state] == 'canceled' || order[:state] == 'success'
                            error!({ errors: ['p2p_order.information_chat.can_not_send_message_order_is_done'] }, 422)
                        end
                        
                        chat = ::P2pChat.create(chat_params(order, nil))
                        error!(chat.errors.details, 422) unless chat.save

                        present chat

                    rescue Excon::Error => e
                        Rails.logger.error e
                        error!('Connection error', 422)
                    end

                    get '/information_chat/:order_number' do
                        order = ::P2pOrder.joins(:p2p_offer).find_by(order_number: params[:order_number])
                        room = ::P2pChat.joins(:p2p_order).select("p2p_chats.*","p2p_chats.user_uid as p2p_user").where(p2p_orders: { order_number: params[:order_number] })
                        room.each do |chat|
                            if chat[:user_uid] != 'Nusablocks'
                                chat[:p2p_user] = chat_user(chat[:user_uid])
                            end
                        end

                        if order[:p2p_user_id] != p2p_user_id[:id]
                            target = ::P2pUser.joins(:member).find_by(members: {uid: order[:maker_uid]})
                        else
                            target = ::P2pUser.joins(:member).find_by(members: {uid: order[:taker_uid]})
                        end

                        present :target, target, with: API::V1::Account::Entities::Stats
                        present :room, room, with: API::V1::Entities::Chat
                    end

                    desc 'Information Chat Detail'
                    get '/information_chats/:chat_id' do 
                        chat = ::P2pChat.find_by_id(params[:chat_id])
                        
                        present chat.upload.url, disposition: 'inline'
                    end

                    desc 'Detail P2p Order By Order Number'
                    get '/:order_number' do
                        order = ::P2pOrder.select("p2p_orders.*","p2p_orders.p2p_payment_user_id as payment").find_by(order_number: params[:order_number])

                        if order[:p2p_payment_user_id].present?
                            order[:payment] = order_payments(order)
                        end

                        offer = ::P2pOffer.select("p2p_offers.*", "p2p_offers.created_at as payment","p2p_offers.updated_at as trader", "p2p_offers.p2p_pair_id as currency").find_by(id: order[:p2p_offer_id])
                        payments = ::P2pPaymentUser.joins(:p2p_offer_payment, :p2p_payment)
                                                    .select("p2p_payments.*","p2p_offer_payments.*","p2p_offer_payments.id as p2p_payments")
                                                    .find_by(p2p_offer_payments: {p2p_offer_id: offer[:id]})
                        
                        offer[:payment] = payments
                        offer[:currency] = currency(offer[:currency])[:currency].upcase

                        feedback = ::P2pOrderFeedback.joins(p2p_order: :p2p_offer)
                                            .select("p2p_order_feedbacks.*", "p2p_orders.p2p_payment_user_id as payment", "p2p_orders.p2p_user_id as member")
                                            .find_by(p2p_order_feedbacks: {order_number: order[:order_number]})

                        if offer[:side] == 'sell'
                            payment_merchant = ::P2pOfferPayment.joins(p2p_payment_user: :p2p_payment).select("p2p_offer_payments.id","p2p_payment_users.payment_user_uid","p2p_payments.name as bank","p2p_payment_users.name as account_name","p2p_payment_users.name","p2p_payments.logo_url","p2p_payments.base_color","p2p_payment_users.account_number","p2p_payments.state").where(p2p_offer_payments: {p2p_offer_id: offer[:id]})
                        end

                        present :order, order, with: API::V1::Entities::Order
                        present :offer, offer, with: API::V1::Market::Entities::Offer
                        if offer[:side] == 'sell'
                            present :payment_user, payment_merchant, with: API::V1::Entities::PaymentUser
                        end
                        present :feedback, feedback.present? ? feedback : [], with: API::V1::Market::Entities::Feedback
                    end

                    desc 'Confirmation Target Payment final step'
                    put '/confirm/:order_number' do
                        order = ::P2pOrder.find_by(order_number: params[:order_number])
                        if order[:p2p_payment_user_id].blank?
                            error!({ errors: ['p2p_order.order.payment_confirm_not_exists'] }, 422)
                        end

                        if order[:state] == 'completed'
                            error!({ errors: ['p2p_order.order.already_completed_process'] }, 422)
                        end

                        if order[:side] == 'buy'
                            if order[:state] == 'waiting' && p2p_user_id[:uid] == order[:maker_uid] || order[:state] == 'accepted' && p2p_user_id[:uid] == order[:taker_uid]
                                error!({ errors: ['p2p_order.order.can_not_confirm_by_your_self'] }, 422)
                            end
                        else
                            if order[:state] == 'waiting' && p2p_user_id[:uid] == order[:taker_uid] || order[:state] == 'accepted' && p2p_user_id[:uid] == order[:maker_uid]
                                error!({ errors: ['p2p_order.order.can_not_confirm_by_your_self'] }, 422)
                            end
                        end

                        if order[:state] == 'waiting'
                            state = 'accepted'
                            approved = p2p_user_id[:uid] == order[:maker_uid] ? p2p_user_id[:uid] : order[:taker_uid]
                            order.update({state: state, aproved_by: approved})
                        elsif order[:state] == 'accepted'
                            state = 'success'
                            order.update({state: state})
                        end

                        present order

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

                        if order[:side] == 'buy'
                            payment = ::P2pOfferPayment.joins(:p2p_payment_user, :p2p_offer).find_by(p2p_payment_users: {payment_user_uid: params[:payment_method]}, p2p_offer_payments: {p2p_offer_id: order[:p2p_offer_id]})
                            if payment.blank?
                                error!({ errors: ['p2p_order.order.payment_user_not_found'] }, 422)
                            end
                        end

                        order.update({
                            p2p_payment_user_id: order[:side] == 'buy' ? payment[:id] : order[:p2p_payment_user_id],
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

                        order.update({state: "canceled", aproved_by: current_user[:uid]})
                        present order
                    end

                    desc 'Report merchant when order progress'
                    params do
                        optional :reason
                        optional :uplaod_payment,
                                desc: 'Array of Rack::Multipart::UploadedFile'
                        optional :text_message,
                                type: String,
                                desc: 'Description of reported by order user'
                    end
                    post '/report/:order_number' do
                        order = ::P2pOrder.find_by(order_number: params[:order_number])
                        
                        error!({ errors: ['p2p_order.report.have_done_a_report_on_this_order'] }, 422) unless order[:state] != 'rejected'

                        params[:reason].each do |param|
                            if param[:key].blank?
                                error!({ errors: ['p2p_order.order.report.reason_key_can_not_blank'] }, 422)
                            end

                            if param[:message].blank?
                                error!({ errors: ['p2p_order.order.report.message_can_not_blank'] }, 422)
                            end
                        end

                        report = ::P2pUserReport.create(report_params)
                        error!(report.errors.details, 422) unless report.save

                        params[:reason].each do |param|
                            ::P2pUserReportDetail.create!(report_detail(report[:id], param))
                        end

                        if params[:upload_payment].present?
                            payment = ::P2pUserReportDetail.create!({p2p_user_report_id: report[:id], key: 'upload', reason: params[:upload_payment]['filename'], upload: params[:upload_payment]['tempfile']})
                            error!(payment.errors.details, 422) unless payment.save
                        end

                        if params[:text_message].present?
                            text = ::P2pUserReportDetail.create!({p2p_user_report_id: report[:id], key: 'text_message', reason: params[:text_message], upload: nil})
                            error!(text.errors.details, 422) unless text.save
                        end

                        order = ::P2pOrder.find_by(order_number: params[:order_number])
                        if order.present?
                            order.update(state: 'rejected', second_approve_expire_at: Time.now)
                        end

                        present report, with: API::V1::Entities::Report
                    rescue Excon::Error => e
                        Rails.logger.error e
                        error!({ errors: ['p2p_order.order.report.error_#{e}'] }, 422)
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