# encoding: UTF-8
# frozen_string_literal: true

module API
    module V1
      module Admin
        module Entities
            class Offer < Grape::Entity
                format_with(:iso8601) {|t| t.to_time.in_time_zone(Rails.configuration.time_zone).iso8601 if t }

                expose(
                    :offer_number,
                    as: :offer_number,
                    documentation: {
                        desc: 'Offer Number Trade.',
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
                    :price,
                    as: :price,
                    documentation: {
                        desc: 'Filter Fiat.',
                        type: String
                    }
                )

                expose(
                    :fiat,
                    documentation: {
                        desc: 'Filter Fiat.',
                        type: String
                    }
                ) { |p2p_offer| p2p_offer.fiat_currency[:fiat] }
    
                expose(
                    :currency,
                    as: :currency,
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
                    }
                )
    
                expose(
                    :min_order_amount,
                    as: :min_order,
                    documentation: {
                        desc: 'Filter Fiat.',
                        type: String
                    }
                )
    
                expose(
                    :max_order_amount,
                    as: :max_order,
                    documentation: {
                        desc: 'Filter Fiat.',
                        type: String
                    }
                )
    
                expose(
                    :paymen_limit_time,
                    as: :payment_time,
                    documentation: {
                        desc: 'Filter Fiat.',
                        type: String
                    }
                )
    
                expose(
                    :term_of_condition,
                    as: :term_of_condition,
                    documentation: {
                        desc: 'Filter Fiat.',
                        type: String
                    }
                )
    
                expose(
                    :sum_order,
                    as: :sum_order,
                    documentation: {
                        desc: 'All Order From Post Offer',
                        type: Integer
                    }
                )
    
                expose(
                    :persentage,
                    as: :persentage,
                    documentation: {
                        desc: 'All Order From Post Offer',
                        type: String
                    }
                )
    
                expose :member, as: :trader, using: API::V1::Admin::Entities::Trader
                expose :payment,
                        documentation: {
                            desc: 'All Payment Offer',
                        } do |p2p_offer|
                            p2p_offer.payment
                        end

                expose :p2p_orders, using: API::V1::Admin::Entities::OfferOrder

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