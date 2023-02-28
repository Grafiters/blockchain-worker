# encoding: UTF-8
# frozen_string_literal: true

module API
    module V1
      module Market
        module Entities
            class Feedback < Grape::Entity
                format_with(:iso8601) {|t| t.to_time.in_time_zone(Rails.configuration.time_zone).iso8601 if t }
    
                expose(
                    :order_number,
                    as: :order_number,
                    documentation: {
                        type: String,
                        desc: 'Order Number'
                    }
                )
    
                expose(
                    :assessment,
                    as: :assesment,
                    documentation: {
                        desc: 'Feedback Assesment',
                        type: String
                    }
                )
    
                expose(
                    :comment,
                    as: :comment,
                    documentation: {
                        desc: 'Feedback Comment',
                        type: String
                    }
                )
    
                expose(
                    :created_at,
                    as: :create,
                    format_with: :iso8601,
                    documentation: {
                        desc: 'Date order',
                        type: String
                    }
                )
            end
          end
        end
    end
end
  