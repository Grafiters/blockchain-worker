module API
    module V1
        module Admin
            class Offer < Grape::API
                helpers ::API::V1::Public::Helpers
                helpers ::API::V1::Admin::Helpers
                helpers ::API::V1::Market::NamedParams
                helpers ::API::V1::Market::RequestParams
                helpers ::API::V1::Market::OfferHelpers

                namespace :offers do
                    desc 'get all data offers'
                    params do
                        optional :offer_number,
                                type: String,
                                desc: -> { V1::Entities::Offer.documentation[:offer_number] }
                        optional :fiat,
                                type: String,
                                desc: -> { V1::Entities::Fiat.documentation[:code] }
                        optional :currency,
                                type: String,
                                desc: -> { V1::Entities::Fiat.documentation[:currency] }
                        optional :side,
                                type: String,
                                desc: 'Side Offer by Sell Or Buy'
                        optional :state,
                                type: String,
                                desc: -> { V1::Entities::Offer.documentation[:state] }
                        use :date_picker
                    end
                    get "/" do
                        search_params = API::V2::Admin::Helpers::RansackBuilder.new(params)
                                                .eq(:side, :state, :offer_number)
                                                .lt_any
                                                .build
                        
                        offer = ::P2pOffer.joins(:p2p_pair).select("p2p_offers.*","p2p_offers.offer_number as sum_order","p2p_offers.offer_number as persentage", "p2p_offers.p2p_user_id as member", "p2p_offers.p2p_pair_id as currency")

                        offer  = offer.where(p2p_pairs: {currency: params[:currency]}) unless params[:currency].blank?
                        offer  = offer.where(p2p_pairs: {fiat: params[:fiat]}) unless params[:fiat].blank?

                        search = offer.ransack(search_params)

                        search.sorts = "id DESC"
                        
                        result = search.result.load
                        data = result.each do |offer|
                            offer[:sum_order] = sum_order(offer[:id])
                            offer[:persentage] = persentage(offer[:id])
                            offer[:currency] = currency(offer[:currency])[:currency].upcase
                            offer[:member] = trader(offer[:p2p_user_id])
                        end

                        present paginate(data), with: API::V1::Admin::Entities::Offer
                    end
                    
                    desc 'Get single data offers'
                    params do
                        optional :offer_number,
                                type: String,
                                desc: -> { V1::Entities::Offer.documentation[:offer_number] }
                        optional :fiat,
                                type: String,
                                desc: -> { V1::Entities::Fiat.documentation[:code] }
                        optional :currency,
                                type: String,
                                desc: -> { V1::Entities::Fiat.documentation[:currency] }
                        optional :side,
                                type: String,
                                desc: 'Side Offer by Sell Or Buy'
                        optional :state,
                                type: String,
                                desc: -> { V1::Entities::Offer.documentation[:state] }
                        use :date_picker
                    end
                    get "/:offer_number" do
                        search_params = API::V2::Admin::Helpers::RansackBuilder.new(params)
                                                .eq(:side, :state, :offer_number)
                                                .lt_any
                                                .build
                        
                        offer = ::P2pOffer.joins(:p2p_pair).select("p2p_offers.*","p2p_offers.offer_number as sum_order","p2p_offers.offer_number as persentage", "p2p_offers.p2p_user_id as member", "p2p_offers.p2p_pair_id as currency")

                        offer[:sum_order] = sum_order(offer[:id])
                        offer[:persentage] = persentage(offer[:id])
                        offer[:currency] = currency(offer[:currency])[:currency].upcase
                        offer[:member] = trader(offer[:p2p_user_id])
                    

                        present paginate(data), with: API::V1::Admin::Entities::Offer
                    end
                end
            end
        end
    end
end