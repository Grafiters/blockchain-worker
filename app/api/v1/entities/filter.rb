# encoding: UTF-8
# frozen_string_literal: true

module API
    module V1
      module Entities
        class Filter < Base
          expose(
            :paymentMethod,
            as: :payment,
            documentation: {
              desc: 'Filter Fiat.',
              type: String
            }
          )
        end
      end
    end
end
  