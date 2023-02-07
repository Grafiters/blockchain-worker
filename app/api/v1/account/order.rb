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
                        order = ::P2pOrder.joins(p2p_offer: :p2p_pair).select("p2p_orders.*", "p2p_offers.*","p2p_pairs.*").where(p2p_orders: {p2p_user_id: current_p2p_user[:id]})

                        present order, with: API::V1::Account::Entities::Order
                    end
                end
            end
        end
    end
end