# encoding: UTF-8
# frozen_string_literal: true

module API
    module V1
      module Entities
        class Order < Base
            expose(
                :order_number,
                as: :order_number,
                documentation: {
                    desc: 'Order Number.',
                    type: String
                }
            )

            expose(
                :maker_uid,
                as: :maker_uid,
                documentation: {
                    desc: 'Filter Fiat.',
                    type: String
                }
            )

            expose(
                :taker_uid,
                as: :taker_uid,
                documentation: {
                    desc: 'Filter Fiat.',
                    type: String
                }
            )

            expose(
                :amount,
                as: :quantity,
                documentation: {
                    desc: 'Filter Fiat.',
                    type: String
                }
            )

            expose :amount,
                    documentation: {
                        desc: 'Count Down Timer',
                        type: String
                    } do |order|
                        order.amount_order
                    end

            expose(
                :state,
                as: :state,
                documentation: {
                    desc: 'Filter Fiat.',
                    type: String
                }
            )

            expose :count_down,
                    documentation: {
                        desc: 'Count Down Timer',
                        type: String
                    } do |order|
                        order.first_count_down_time
                    end

            expose(
                :side,
                as: :side,
                documentation: {
                    desc: 'Filter Fiat.',
                    type: String
                }
            )

            expose :trades,
                    documentation: {
                        desc: 'Count Down Timer',
                        type: String
                    } do |order|
                        order.trades
                    end

            expose :stats,
                    documentation: {
                        type: String,
                        desc: 'Stats merchant'
                    } do |order|
                        order.trade
                    end

            expose(
                :first_approve_expire_at,
                as: :first_approve,
                format_with: :iso8601,
                documentation: {
                    desc: 'The datetimes for the first approve.',
                    type: String
                }
            )

            expose(
                :second_approve_expire_at,
                as: :second_approve,
                format_with: :iso8601,
                documentation: {
                    desc: 'The datetimes for the second approve.',
                    type: String
                }
            )

            expose :payment, using: API::V1::Entities::Payment

            expose(
                :created_at,
                :updated_at,
                format_with: :iso8601,
                documentation: {
                    type: String,
                    desc: 'The datetimes for the p2p order.'
                }
            )
        end
      end
    end
end
  