module API
    module V1
        module Market
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

                    desc 'Get detail selected trade offer'
                    get "/:trade_uid" do
                        
                    end
                end
            end
        end
    end
end