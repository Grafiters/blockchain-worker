module API
    module V1
        module Public
            class Offer < Grape::API
                helpers ::API::V1::Admin::Helpers
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