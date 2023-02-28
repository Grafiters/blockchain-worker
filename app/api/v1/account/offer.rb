module API
    module V1
        module Account
            class Offer < Grape::API
                namespace :offer do
                    helpers ::API::V1::Public::Helpers
                    helpers ::API::V2::Admin::Helpers
                    helpers ::API::V1::Account::Utils
                    helpers ::API::V1::Account::ParamHelpers

                    desc 'Get Offer by current user'
                    params do
                        optional :state,
                                 type: String,
                                 allow_blank: true,
                                 values: { value: %w(prepare waiting accepted success rejected canceled), message: 'p2p_account.order.non_state_params' }
                        optional :side,
                                type: String,
                                desc: 'Side Offer by Sell Or Buy'
                        optional :amount,
                                type: { value: Integer, message: 'market.order.non_integer_limit' }
                        optional :max_amount,
                                type: { value: Integer, message: 'market.order.non_integer_limit' }
                        optional :min_price,
                                type: { value: Integer, message: 'market.order.non_integer_limit' }
                        optional :max_price,
                                type: { value: Integer, message: 'market.order.non_integer_limit' }
                        use :date_picker
                    end
                    get "/" do
                        search_params = API::V2::Admin::Helpers::RansackBuilder.new(params)
                                                .lt_any
                                                .with_range_amount
                                                .build

                        order = ::P2pOffer.joins(:p2p_pair, p2p_offer_payment: :p2p_payment_user)
                                            .select("p2p_offers.*","p2p_offers.offer_number as sum_order","p2p_offers.offer_number as persentage", "p2p_offers.p2p_user_id as payments", "p2p_pairs.fiat","p2p_pairs.currency")
                                            .where(p2p_offers: {p2p_user_id: current_p2p_user[:id]})

                        search = order.ransack(search_params)
                        
                        result = search.result.load
                        data = result.each do |offer|
                            offer[:sum_order] = sum_order(offer[:id])
                            offer[:persentage] = persentage(offer[:id])
                            offer[:payments] = payment_order(offer)
                        end

                        # present paginate(data)
                        present paginate(data), with: API::V1::Account::Entities::Offer
                    end

                    desc 'Detail Offer User on current user'
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
                    get '/:offer_number' do
                        search_params = API::V2::Admin::Helpers::RansackBuilder.new(params)
                                                .lt_any
                                                .with_range_amount
                                                .build
                        
                        offer = ::P2pOffer.joins(:p2p_pair, p2p_offer_payment: :p2p_payment_user)
                                            .select("p2p_offers.*","p2p_offers.offer_number as sum_order","p2p_offers.offer_number as persentage", "p2p_offers.p2p_user_id as payments", "p2p_pairs.fiat","p2p_pairs.currency")
                                            .find_by(p2p_offers: {offer_number: params[:offer_number]})

                        # search = order.ransack(search_params)
                        
                        # result = search.result.load
                        offer[:sum_order] = sum_order(offer[:id])
                        offer[:persentage] = persentage(offer[:id])
                        offer[:payments] = payment_order(offer)

                        search = ::P2pOrder.joins(p2p_offer: :p2p_pair)
                            .select("p2p_orders.*", "p2p_offers.offer_number", "p2p_offers.available_amount", "p2p_pairs.fiat","p2p_pairs.currency","p2p_offers.origin_amount",
                                    "p2p_offers.price", "p2p_offers.price as fiat_amount")
                            .where(p2p_orders: {p2p_offer_id: offer[:id]})
                        
                        order = search.ransack(search_params)
                        
                            # order.sorts = "id DESC"
                        # present params
                        present :offer, offer, with: API::V1::Account::Entities::Offer
                        present :order, paginate(order.result.load), with: API::V1::Account::Entities::Order
                    end

                    desc 'Cancel Offer by current user'
                    put '/cancel/:offer_number' do
                        order = ::P2pOrder.joins(:p2p_offer).where(p2p_offers: {offer_number: params[:offer_number]})

                        error!({ errors: ['p2p_offer.account.some_orders_is_unfinished'] }, 422) unless order.count <= 0

                        offer = ::P2pOffer.find_by(offer_number: params[:offer_number])
                        offer.update(state: 'canceled')

                        present order
                    end
                end
            end
        end
    end
end