module API
    module V1
        module Market
            class Offer < Grape::API
                helpers ::API::V1::Public::Helpers
                helpers ::API::V1::Admin::Helpers
                helpers ::API::V1::Market::NamedParams
                helpers ::API::V1::Market::RequestParams
                helpers ::API::V1::Market::OfferHelpers

                namespace :trades do
                    desc 'Filter available fiat'
                    params do
                        # use :pagination
                        requires :fiat,
                                type: String,
                                desc: -> { V1::Entities::Fiat.documentation[:code] }
                        requires :currency,
                                type: String,
                                desc: -> { V1::Entities::Fiat.documentation[:currency] }
                        requires :side,
                                type: String,
                                desc: 'Side Offer by Sell Or Buy'
                        requires :payment,
                                allow_blank: false
                        optional :amount,
                                type: { value: Integer, message: 'market.order.non_integer_limit' }
                        optional :max_amount,
                                type: { value: Integer, message: 'market.order.non_integer_limit' }
                        optional :min_price,
                                type: { value: Integer, message: 'market.order.non_integer_limit' }
                        optional :max_price,
                                type: { value: Integer, message: 'market.order.non_integer_limit' }
                    end
                    get "/" do
                        search_params = API::V2::Admin::Helpers::RansackBuilder.new(params)
                                                .lt_any
                                                .with_range_amount
                                                .build

                        side = params[:side] == 'buy' ? 'sell' : 'buy'
                        
                        search = ::P2pOffer.joins(:p2p_pair)
                                            .select("p2p_offers.*","p2p_offers.offer_number as sum_order","p2p_offers.offer_number as persentage", "p2p_offers.p2p_user_id as member", "p2p_pairs.created_at as payment", "p2p_offers.p2p_pair_id as currency")
                                            .where(p2p_pairs: {fiat: params[:fiat]})
                                            .where(p2p_pairs: {currency: params[:currency]})
                                            .where(p2p_offers: {side: side})
                                            .ransack(search_params)
                        
                        result = search.result.load
                        data = result.each do |offer|
                            offer[:sum_order] = sum_order(offer[:id])
                            offer[:persentage] = persentage(offer[:id])
                            offer[:currency] = currency(offer[:currency])[:currency].upcase
                            offer[:member] = trader(offer[:p2p_user_id])
                            offer[:payment] = payment(offer[:id])
                        end

                        present paginate(Rails.cache.fetch("offers_#{params}", expires_in: 600) { data }), with: API::V1::Public::Entities::Offer
                    end

                    desc 'Create offer trade'
                        params do
                            use :offer
                        end
                    post do
                        if p2p_user_auth.blank?
                            error!({ errors: ['p2p_user.user.account_p2p_doesnt_exists'] }, 422)
                        end

                        if params[:payment].blank?
                            error!({ errors: ['p2p_user.user.payment_must_be_exists'] }, 422)
                        end

                        check_payment_user

                        create_offer = P2pOffer.create(build_params)

                        create_payment = create_payment_offer(create_offer[:id])

                        present :offer, create_offer
                        present :payment, create_offer.p2p_order_payment
                    end

                    get "/:offer_id" do
                        offer = ::P2pOffer.find_by(offer_number: params[:offer_id])

                        if offer[:side] == 'sell'
                            all_payment = ::P2pPayment.joins(:fiat).where(fiats: {name: 'IDR'})
                        end

                        payment = ::P2pPaymentUser.joins(:p2p_order_payment, :p2p_payment)
                                                    .select("p2p_payments.*","p2p_order_payments.*","p2p_order_payments.id as p2p_payments")
                                                    .where(p2p_order_payments: {p2p_offer_id: offer[:id]})

                        present :offer, offer
                        present :payment, payment
                        if offer[:side] == 'sell'
                            present :all_payment, all_payment
                        end
                    end
                end
            end
        end
    end
end