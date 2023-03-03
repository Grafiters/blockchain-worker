# encoding: UTF-8
# frozen_string_literal: true

module API
    module V1
      module Account
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
    
                expose :fiat,
                    documentation: {
                        desc: 'Order Fiat.',
                        type: String
                    } do |p2p_offer|
                        p2p_offer.fiat_logo
                    end

                expose :currency,
                    documentation: {
                        desc: 'Order Currency.',
                        type: String
                    } do |p2p_offer|
                        p2p_offer.currency_logo
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
                    :state,
                    as: :state,
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

                expose :stats_offer,
                    documentation: {
                        desc: 'Statistic Offer',
                    }do |p2p_offer|
                        p2p_offer.sold
                    end
    
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

                expose :payments, using: API::V1::Entities::Payment
                
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