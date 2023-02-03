module API
    module V1
        module Public
            class Offer < Grape::API
                helpers ::API::V1::Public::Helpers
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
                        # payment = 
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

                        present paginate(Rails.cache.fetch("offers_#{params}", expires_in: 600) { data }), with: API::V1::Entities::Offer
                    end

                    desc 'Get Detail of Offer Trade Number'
                    get "/detail/:offer_number" do
                        trade = ::P2pOffer.find_by(offer_number: params[:offer_number])

                        present trade
                    end

                    desc 'Get Detail Merchant Trade'
                    get "/merchant/:merchant" do
                        merchant = ::Member.find_by(uid: params[:merchant])
                        
                        present merchant
                    end
                end
            end
        end
    end
end