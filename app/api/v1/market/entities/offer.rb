# encoding: UTF-8
# frozen_string_literal: true

module API
    module V1
        module Market
            module Entities
                class Offer < Grape::Entity
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
                end
            end
        end
    end
end
  