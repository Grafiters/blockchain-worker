# encoding: UTF-8
# frozen_string_literal: true

module API
    module V1
      module Entities
        class Currency < Base
          expose(
            :fiat,
            as: :fiat,
            documentation: {
              desc: 'Filter Fiat.',
              type: String
            }
          )

          expose(
            :currency,
            as: :currency,
            documentation: {
              desc: 'Filter Currency.',
              type: String
            }
          )

          expose(
            :state,
            as: :state,
            documentation: {
              desc: 'Filter Currency.',
              type: String
            }
          )

        end
      end
    end
  end
  