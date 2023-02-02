# encoding: UTF-8
# frozen_string_literal: true

module API
    module V1
      module Market
        module NamedParams
          extend ::Grape::API::Helpers

          params :offer do
            requires :fiat,
                      type: String,
                      desc: -> { V1::Entities::Fiat.documentation[:fiat] }
            requires :currency,
                      type: String,
                      desc: -> { V1::Entities::Currency.documentation[:currency] }
            requires :price,
                      type: {value: BigDecimal, message: 'market.offer.price_invalid_value'}
            requires :trade_amount,
                      type: {value: BigDecimal, message: 'market.offer.trade_amount_invalid_value'}
            requires :min_order,
                      type: {value: BigDecimal, message: 'market.offer.min_order_invalid_value'}
            requires :max_order,
                      type: {value: BigDecimal, message: 'market.offer.max_order_invalid_value'}
            requires :side,
                      type: String,
                      values: { value: %w(buy sell), message: 'market.offer.invalid_side' }
            # optional :payment,
            #           values: { value: ->(v) { Array.wrap(v).blank? }, message: 'market.offer.payment_invalid_value' }
            optional :term_of_condition,
                      type: String
            optional :auto_replay,
                      type: String
          end
        end
      end
    end
end
  