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
                        optional :currency,
                                 type: String
                        optional :state,
                                 type: String,
                                 allow_blank: true,
                                 values: { value: %w(prepare waiting accepted rejected canceled success), message: 'p2p_account.order.invalid_state_filter' }
                        optional :from,
                                allow_blank: { value: false, message: 'account.transactions.empty_time_from' },
                                type: { value: Integer, message: 'account.transactions.non_integer_time_from' },
                                desc: 'An integer represents the seconds elapsed since Unix epoch.'

                        optional :to,
                                type: { value: Integer, message: 'account.transactions.non_integer_time_to' },
                                allow_blank: { value: false, message: 'account.transactions.empty_time_to' },
                                desc: 'An integer represents the seconds elapsed since Unix epoch.'
                        
                    end
                    get "/" do
                        ransack_params = API::V1::Admin::Helpers::RansackBuilder.new(params)
                                        .build

                        side = params[:side] == 'sell' ? 'buy' : 'sell'

                        data = ::P2pOrder.joins(p2p_offer: :p2p_pair)
                            .select("p2p_orders.*", "p2p_offers.offer_number", "p2p_offers.available_amount", "p2p_pairs.fiat","p2p_pairs.currency","p2p_offers.origin_amount",
                                    "p2p_offers.price", "p2p_offers.price as fiat_amount")
                        data = data.where('(p2p_orders.p2p_user_id = ? AND p2p_orders.side = "buy")
                                        OR
                                    (p2p_orders.p2p_user_id = ? AND p2p_orders.side = "sell")
                                        OR
                                    (p2p_offers.p2p_user_id = ? AND p2p_offers.side = "buy")
                                        OR
                                    (p2p_offers.p2p_user_id = ? AND p2p_offers.side = "sell")', current_p2p_user[:id], current_p2p_user[:id], current_p2p_user[:id], current_p2p_user[:id]) unless params[:side].present?
                        
                        data = data.where('(p2p_orders.p2p_user_id = ? AND p2p_orders.side = ?)
                                            OR
                                            (p2p_offers.p2p_user_id = ? AND p2p_offers.side = ?)', current_p2p_user[:id], params[:side], current_p2p_user[:id], params[:side]) unless params[:side].blank?
                        
                        data = data.where(p2p_orders: {state: params[:state]}) unless params[:state].blank?
                        data = data.joins(p2p_offer: :p2p_pair).where(p2p_pairs: {fiat: params[:fiat]}) unless params[:fiat].blank?            
                        data = data.joins(p2p_offer: :p2p_pair).where(p2p_pairs: {currency: params[:currency]}) unless params[:currency].blank?
                        data = data.where('p2p_orders.created_at >= ?', Time.at(params[:from])) unless params[:to].blank? 
                        data = data.where('p2p_orders.created_at <= ?', Time.at(params[:to]+24*60*60)) unless params[:to].blank?
                        data = data.order(id: :desc)

                        data = data.ransack(ransack_params)

                        present paginate(data.result.each do |ord|
                            ord[:state] = state_order(ord)
                        end), with: API::V1::Account::Entities::Order, current_user: current_p2p_user[:id]
                    end
                end
            end
        end
    end
end