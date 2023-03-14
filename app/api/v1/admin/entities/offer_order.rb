# encoding: UTF-8
# frozen_string_literal: true

module API
    module V1
      module Admin
        module Entities
            class OfferOrder < Grape::Entity
                format_with(:iso8601) {|t| t.to_time.in_time_zone(Rails.configuration.time_zone).iso8601 if t }

                expose(
                    :maker,
                    as: :maker,
                    using: API::V1::Admin::Entities::Member,
                    documentation: {
                        desc: 'Offer Number.',
                        type: String
                    }
                )

                expose(
                    :taker,
                    as: :taker,
                    using: API::V1::Admin::Entities::Member,
                    documentation: {
                        desc: 'Offer Number.',
                        type: String
                    }
                )

                expose(
                    :order_number,
                    as: :order_number,
                    documentation: {
                        desc: 'Order Number.',
                        type: String
                    }
                )

                expose(
                    :amount,
                    as: :amount,
                    documentation: {
                        desc: 'Filter Fiat.',
                        type: String
                    }
                )

                expose :state,
                    documentation: {
                        desc: 'Filter Fiat.',
                        type: String
                    } do |p2p_order|
                        p2p_order.state_canceled
                    end
    
                expose(
                    :side,
                    as: :side,
                    documentation: {
                        desc: 'Filter Fiat.',
                        type: String
                    }
                )

                expose(
                    :is_issue,
                    as: :is_issue,
                    documentation: {
                        desc: 'Order Have Issue or Not.',
                        type: String
                    }
                )
                    
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
end
  