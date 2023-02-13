# encoding: UTF-8
# frozen_string_literal: true

module API
    module V1
      module Account
        module Entities
            class Order < Grape::Entity
                format_with(:iso8601) {|t| t.to_time.in_time_zone(Rails.configuration.time_zone).iso8601 if t }

                expose(
                    :order_number,
                    as: :order_number,
                    documentation: {
                        desc: 'Order Number.',
                        type: String
                    }
                )

                expose(
                    :offer_number,
                    as: :offer_number,
                    documentation: {
                        desc: 'Offer Number.',
                        type: String
                    }
                )

                expose :fiat,
                    documentation: {
                        desc: 'Order Fiat.',
                        type: String
                    } do |p2p_order|
                        p2p_order.fiat_logo
                    end

                expose :currency,
                    documentation: {
                        desc: 'Order Currency.',
                        type: String
                    } do |p2p_order|
                        p2p_order.currency_logo
                    end

                expose :fiat_amount,
                    documentation: {
                        desc: 'Filter Fiat.',
                        type: String
                    } do |p2p_order|
                        p2p_order.fiat_amounts
                    end
    
                expose(
                    :amount,
                    as: :amount,
                    documentation: {
                        desc: 'Filter Fiat.',
                        type: String
                    }
                )

                expose(
                    :price,
                    as: :price,
                    documentation: {
                        desc: 'Filter Fiat.',
                        type: String
                    }
                )

                expose(
                    :available_amount,
                    as: :available_amount,
                    documentation: {
                        desc: 'Filter Fiat.',
                        type: String
                    }
                )

                expose(
                    :origin_amount,
                    as: :origin_amount,
                    documentation: {
                        desc: 'Filter Fiat.',
                        type: String
                    }
                )
    
                expose :trades,
                        documentation: {
                            type: String,
                            desc: 'Trades Order.'
                        } do |p2p_order|
                            p2p_order.trades
                        end

                expose(
                    :state,
                    as: :state,
                    documentation: {
                        desc: 'Filter Fiat.',
                        type: String
                    }
                )
    
                expose(
                    :side,
                    as: :side,
                    documentation: {
                        desc: 'Filter Fiat.',
                        type: String
                    },
                    if: ->(_, options) { options[:current_user] }
                    ) do |trade, options|
                        side_status(trade, options[:current_user])
                    end

                expose(
                    :created_at,
                    :updated_at,
                    format_with: :iso8601,
                    documentation: {
                        type: String,
                        desc: 'The datetimes for the p2p order.'
                    }
                )

                def trades
                    if order.p2p_user_id != current_user && order.side == 'sell'
                        Member.joins(:p2p_user).select("p2p_users.username","members.email").find_by(members: {uid: maker_uid})
                    else
                        Member.joins(:p2p_user).select("p2p_users.username","members.email").find_by(members: {uid: taker_uid})
                    end
                end

                def side_status(order, current_user)
                    order.p2p_user_id != current_user ? 'sell' : 'buy'
                end
            end
          end
        end
    end
end
  