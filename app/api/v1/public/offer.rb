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
                        search_params = API::V2::Admin::Helpers::RansackBuilder.new(params)
                                                .lt_any
                                                .with_range_amount
                                                .build

                        side = params[:side] == 'buy' ? 'sell' : 'buy'
                        
                        order = ::P2pOffer.joins(:p2p_pair, p2p_order_payment: :p2p_payment_user)
                                            .select("p2p_offers.*","p2p_offers.offer_number as sum_order","p2p_offers.offer_number as persentage", "p2p_offers.p2p_user_id as member", "p2p_offers.p2p_pair_id as currency")
                                            .where(p2p_pairs: {fiat: params[:fiat]})
                                            .where(p2p_pairs: {currency: params[:currency]})
                                            .where(p2p_offers: {side: side})
                                            .where.not(p2p_offers: {state: 'canceled'})
                        order = order.where('p2p_payment_users.p2p_payment_id IN (?)', params[:payment]) unless params[:payment].blank? || params[:payment][0] == ""
                        search = order.ransack(search_params)
                        
                        result = search.result.load
                        data = result.each do |offer|
                            offer[:sum_order] = sum_order(offer[:id])
                            offer[:persentage] = persentage(offer[:id])
                            offer[:currency] = currency(offer[:currency])[:currency].upcase
                            offer[:member] = trader(offer[:p2p_user_id])
                        end

                        # present params
                        present paginate(data), with: API::V1::Public::Entities::Offer
                    end

                    desc 'Get Detail of Offer Trade Number'
                    get "/detail/:offer_number" do
                        trade = ::P2pOffer.find_by(offer_number: params[:offer_number])

                        present trade
                    end

                    desc 'Get Detail Merchant Trade'
                    get "/merchant/:merchant" do
                        member = ::P2pUser.joins(:member).find_by(members: {uid: params[:merchant]})

                        if member.blank?
                            member = p2p_user
                        end

                        present member, with: API::V1::Account::Entities::Stats, masking: true
                    end
                end
            end
        end
    end
end