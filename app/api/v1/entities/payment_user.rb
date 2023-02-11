# encoding: UTF-8
# frozen_string_literal: true

module API
    module V1
      module Entities
        class PaymentUser < Base
            expose(
                :id,
                as: :payment_user_id,
                documentation: {
                    desc: 'Filter Fiat.',
                    type: String
                }
            )

            expose(
                :bank,
                as: :bank,
                documentation: {
                    desc: 'Filter Fiat.',
                    type: String
                }
            )

            expose(
                :name,
                as: :account_name,
                documentation: {
                    desc: 'Filter Fiat.',
                    type: String
                }
            )

            expose(
                :account_number,
                as: :account_number,
                documentation: {
                    desc: 'Filter Fiat.',
                    type: String
                }
            )

            expose(
                :logo_url,
                as: :logo,
                documentation: {
                    desc: 'Filter Fiat.',
                    type: String
                }
            )

            expose(
                :base_color,
                as: :base_color,
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
        end
      end
    end
end
  