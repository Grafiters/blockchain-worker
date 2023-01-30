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
                        use :pagination
                        requires :fiat,
                                type: String,
                                desc: -> { V2::Entities::Market.documentation[:symbol] }
                        requires :currency,
                                type: String,
                                desc: -> { V2::Entities::Market.documentation[:symbol] }
                    end
                    get "/" do
                        user_authorize! :read, ::P2pOffer
                        search_params = API::V2::Admin::Helpers::RansackBuilder.new(params)
                                                .lt_any
                                                .build

                        side = params[:side] == 'buy' ? 'sell' : 'buy'
                        search = ::P2pOffer.joins(:p2p_pair)
                                            .select("p2p_offers.*", "p2p_offers.p2p_user_id as trader", "p2p_pairs.created_at as payment", "p2p_offers.p2p_pair_id as currency")
                                            .where(p2p_pairs: {fiat: params[:fiat]})
                                            .where(p2p_pairs: {currency: params[:currency]})
                                            .where(p2p_offers: {side: side})
                                            .ransack(search_params)
                        
                        result = search.result.load
                        data = result.each do |offer|
                            offer[:currency] = currency(offer[:currency])[:currency].upcase
                            offer[:trader] = trader(offer[:p2p_user_id])
                            offer[:payment] = payment(offer[:id])
                        end

                        present paginate(Rails.cache.fetch("offers_#{params}", expires_in: 600) { data }), with: API::V1::Entities::Offer
                    end

                    desc 'Create offer trade'
                    post do
                        user_authorize! :create, ::P2pOffer

                        create_offer = P2pOffer.create(build_params)

                        create_payment = create_payment_offer(create_offer[:id])

                        present :offer, create_offer
                        present :payment, create_payment
                    end

                    get "/:offer_id" do
                        user_authorize! :read, ::P2pOffer
                        offer = ::P2pOffer.find_by(offer_number: params[:offer_id])
                        payment = ::P2pPaymentUser.joins(:p2p_order_payment, :p2p_payment)
                                                    .select("p2p_payments.*","p2p_order_payments.*","p2p_order_payments.id as p2p_payments")
                                                    .where(p2p_order_payments: {p2p_offer_id: offer[:id]})

                        present :offer, offer
                        present :payment, payment
                    end
                end
            end
        end
    end
end