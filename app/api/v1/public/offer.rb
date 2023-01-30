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
                                desc: -> { V2::Entities::Market.documentation[:symbol] }
                        requires :currency,
                                type: String,
                                desc: -> { V2::Entities::Market.documentation[:symbol] }
                    end
                    get "/" do
                        search_params = params[:search]

                        side = params[:side] == 'buy' ? 'sell' : 'buy'
                        search = ::P2pOffer.joins(:p2p_pair)
                                            .select("p2p_offers.*", "p2p_offers.p2p_user_id as trader", "p2p_pairs.created_at as payment")
                                            .where(p2p_pairs: {fiat: params[:fiat]})
                                            .where(p2p_pairs: {currency: params[:currency]})
                                            .where(p2p_offers: {side: side})
                                            .ransack(search_params)

                        # search = ::P2pUser.joins(:member, :p2p_offer)
                        #                     .select("p2p_users.*","members.*","p2p_offers.*","p2p_offers.id as payment")
                        #                     .where(p2p_offers: {p2p_pair_id: pairs[:id]})
                        #                     .where(p2p_offers: {side: side})
                        #                     .ransack(search_params)
                        
                        result = search.result.load
                        data = result.each do |offer|
                            offer[:trader] = trader(offer[:p2p_user_id])
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