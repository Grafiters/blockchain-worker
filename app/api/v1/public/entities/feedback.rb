# encoding: UTF-8
# frozen_string_literal: true

module API
    module V1
      module Public
        module Entities
            class Feedback < Grape::Entity
                format_with(:iso8601) {|t| t.to_time.in_time_zone(Rails.configuration.time_zone).iso8601 if t }
                expose :member, with: API::V1::Account::Entities::Member
    
                expose(
                    :order_number,
                    as: :order_number,
                    documentation: {
                        type: String,
                        desc: 'Order Number'
                    }
                )
    
                expose(
                    :payment_limit,
                    as: :timer,
                    documentation: {
                        type: String,
                        desc: 'Timer Transaction of order'
                    }
                )
    
                expose :payments, with: API::V1::Public::Entities::Payment
    
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
                    :p2p_start,
                    as: :date_transaction_start,
                    format_with: :iso8601,
                    documentation: {
                        desc: 'Date order',
                        type: String
                    }
                )
    
                expose(
                    :p2p_end,
                    as: :date_transaction_end,
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
  