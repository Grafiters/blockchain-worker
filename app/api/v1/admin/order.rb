module API
    module V1
        module Admin
            module Market
                class Order < Grape::API
                    helpers ::API::V1::Public::Helpers
                    helpers ::API::V1::Admin::Helpers
                    helpers ::API::V1::Market::NamedParams
                    helpers ::API::V1::Market::RequestParams
                    helpers ::API::V1::Market::OfferHelpers
    
                    namespace :orders do
                        desc 'Get available fiat'
                        params do
                            optional :fiat,
                                    type: String
                            optional :side,
                                    type: String
                            optional :state,
                                    type: String,
                                    allow_blank: true,
                                    values: { value: %w(prepare waiting accepted rejected canceled), message: 'p2p_account.order.non_integer_limit' }
                            use :date_picker
                        end
                        get "/" do
                            ransack_params = API::V1::Admin::Helpers::RansackBuilder.new(params)
                                            .eq(:side, :state, :fiat)
                                            .with_daterange
                                            .build

                            order = ::P2pOrder.joins(p2p_offer: :p2p_pair)
                                .select("p2p_orders.*", "p2p_offers.offer_number", "p2p_offers.available_amount", "p2p_pairs.fiat","p2p_pairs.currency","p2p_offers.origin_amount",
                                        "p2p_offers.price", "p2p_offers.price as fiat_amount")
                                .ransack(ransack_params)
                            
                            order.sorts = "id DESC"

                            present paginate(order.result)
                        end

                        desc 'Get order details'
                        params do
                            requires :order_number,
                                    type: String,
                                    allow_blank: false,
                                    desc: 'Order number'
                            requires :action,
                                    type: String,
                                    allow_blank: false
                                    values: { value: %w(process canceled), message: 'admin.p2p_order.invalid_actions_params' }
                            optional :member_uid,
                                    type: String,
                                    allow_blank: true
                        post '/actions' do
                            order = ::Order.find_by(order_number: params[:order_number])

                            order.update(state: params[:state]) unless params[:action] != 'canceled'

                            if params[:action] == 'process'
                                error!({ errors: ['admin.p2p_order.member_uid_undifined'] }, 422) unless params[:member_uid].present?
                            end

                            present order
                        end

                        get '/room_chat/:order_number' do
                            order = ::P2pOrder.joins(:p2p_offer).find_by(order_number: params[:order_number])
                            room = ::P2pChat.joins(:p2p_order).select("p2p_chats.*","p2p_chats.user_uid as p2p_user").where(p2p_orders: { order_number: params[:order_number] })

                            present :order, order
                            present :room, room, with: API::V1::Entities::Chat
                        end

                        desc 'Post confirmation message from admin'
                        params do
                            requires :message,
                                    allow_blank: false,
                                    desc: 'Confirmation message'
                        end
                        post '/room_chat/:order_number' do
                            order = ::P2pOrder.find_by_order_number(order_number: params[:order_number])

                            if order[:state] == 'canceled' || order[:state] == 'success'
                                error!({ errors: ['admin.p2p_order.can_not_send_message_order_is_done'] }, 422)
                            end

                            chat = ::P2pChat.create(chat_params(order))
                            error!(chat.errors.details, 422) unless chat.save

                            present chat, with: API::V1::Entities::Chat
                        end
                    end
                end
            end
        end
    end
end