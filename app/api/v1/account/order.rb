module API
    module V1
        module Account
            class Order < Grape::API
                namespace :order do
                    helpers ::API::V2::Admin::Helpers
                    helpers ::API::V1::Account::Utils
                    helpers ::API::V1::Account::ParamHelpers

                    desc 'Get available fiat'
                    get "/" do
                        order = ::P2pOrder.joins(:p2p_offer).select("p2p_orders.*", "p2p_offers.*").where(p2p_offer_id: current_p2p_user[:id])

                        present current_p2p_user
                    end

                    desc 'Create new payment method for user p2p'
                    post do
                        
                    end
                end
            end
        end
    end
end