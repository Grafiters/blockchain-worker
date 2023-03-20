# encoding: UTF-8
# frozen_string_literal: true

module API
    module V1
      module Entities
        class Payment < Base
            expose(
                :payment_user_uid,
                as: :payment_user_uid,
                documentation: {
                    desc: 'Filter Fiat.',
                    type: String
                }
            )

            expose :account_name,
                    documentation: {
                        type: String,
                        desc: 'Account name payment method user'
                    }

            expose :account_number,
                    documentation: {
                        type: String,
                        desc: 'Account Number payment method user'
                    }

            expose(
                :name,
                as: :bank_name,
                documentation: {
                    desc: 'Filter Fiat.',
                    type: String
                }
            )

            expose(
                :symbol,
                as: :symbol,
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

            expose :qrcode,
               documentation: {
                    type: 'String',
                    desc: 'File url and type'
               } do |p2p_payment_user|
                {
                    image: p2p_payment_user
                }
            end

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
  