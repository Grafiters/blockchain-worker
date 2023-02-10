module API
    module V1
        module Account
            class Order < Grape::API
                namespace :order do
                    helpers ::API::V2::Admin::Helpers
                    helpers ::API::V1::Account::Utils
                    helpers ::API::V1::Account::ParamHelpers

                    desc 'Get available fiat'
                    params do
                        optional :fiat,
                                 type: String
                        optional :side,
                                 type: String
                        optional :state,
                                 type: String,
                                 allow_blank: true,
                                 values: { value: %w(prepare waiting accepted rejected canceled), message: 'p2p_account.order.non_integer_limit' }
                        optional :from,
                                 allow_blank: {value: true, message: 'p2p_account.order.empty_time_from'},
                                 type: { value: Integer, message: 'p2p_account.order.non_integer_time_from' },
                                 desc: 'An Integer represents the second elapsed since Unix epoch'
                        optional :to,
                                 allow_blank: {value: true, message: 'p2p_account.order.empty_time_to'},
                                 type: { value: Integer, message: 'p2p_account.order.non_integer_time_to' },
                                 desc: 'An Integer represents the second elapsed since Unix epoch'
                    end
                    get "/" do
                        ransack_params = API::V1::Admin::Helpers::RansackBuilder.new(params)
                                        .eq(:side, :state)
                                        .with_daterange
                                        .build

                        order = ::P2pOrder.joins(p2p_offer: :p2p_pair)
                            .select("p2p_orders.*", "p2p_offers.offer_number", "p2p_offers.available_amount", "p2p_pairs.fiat","p2p_offers.origin_amount",
                                    "p2p_offers.price", "p2p_offers.price as fiat_amount")
                            .where('(p2p_orders.p2p_user_id = ? AND p2p_orders.side = "buy")
                                        OR
                                    (p2p_offers.p2p_user_id = ? AND p2p_offers.side = "sell")', p2p_user[:id], p2p_user[:id])
                            .ransack(ransack_params)

                        present order.result.load.to_a, with: API::V1::Account::Entities::Order, current_user: p2p_user[:id]
                    end
                end
            end
        end
    end
end