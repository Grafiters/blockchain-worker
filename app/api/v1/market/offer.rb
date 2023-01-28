module API
    module V1
        module Market
            class Offer < Grape::API
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
                        search_params = params[:search]

                        search = ::P2pOffer.joins(:p2p_pair)
                                            .where(p2p_pairs: {fiat: params[:fiat]})
                                            .where(p2p_pairs: {currency: params[:currency]})
                                            .ransack(search_params)
                        
                        present paginate(Rails.cache.fetch("markets_#{params}", expires_in: 600) { search.result.load.to_a })
                    end

                    desc 'Create offer trade'
                    post do
                        user_authorize! :create, ::P2pOffer

                        create_offer = P2pOffer.create(build_params)

                        create_payment = create_payment_offer(create_offer[:id])

                        present :offer. create_offer
                        present :payment. create_payment
                    end

                    get "/:offer_id" do
                        user_authorize! :read, ::P2pOffer
                        offer = ::P2pOffer.find_by(offer_number: params[:offer_id])
                        payment = ::P2pOrderPayment.joins(:p2p_payment_user).select("p2p_order_payments.*", "p2p_payment_users.*").where(p2p_offer_id: offer[:id])

                        present :offer, offer
                        present :payment, payment
                    end 
                end
            end
        end
    end
end