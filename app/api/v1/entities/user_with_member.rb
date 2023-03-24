# encoding: UTF-8
# frozen_string_literal: true

module API
    module V1
      module Entities
        class UserWithMember < Base
            expose :member, with: API::V1::Entities::Member

            expose(
                :username,
                as: :trader_name,
                documentation: {
                    desc: 'Trader Username',
                    type: String
                }
            )

            expose(
                :logo,
                as: :logo,
                documentation: {
                    desc: 'Trader logo.',
                    type: String
                }
            )
            
            expose(
                :offers_count,
                as: :offer,
                documentation: {
                    desc: 'Trader Offer.',
                    type: String
                }
            )

            expose(
                :success_rate,
                as: :success_rate,
                documentation: {
                    desc: 'Trader Success Rate.',
                    type: String
                }
            )

            expose(
                :banned_state,
                as: :banned_state,
                documentation: {
                    desc: 'Trader Banned State.',
                    type: String
                }
            )

            expose :p2p_payment_user,
                as: :payment, using: API::V1::Admin::Entities::PaymentUser,
                documentation: {
                    desc: 'Members is payment method for p2p trade'
                }
        end
      end
    end
end
  