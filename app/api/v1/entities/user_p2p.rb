# encoding: UTF-8
# frozen_string_literal: true

module API
    module V1
      module Entities
        class UserP2p < Base
            expose :member, with: API::V2::Entities::Member

            expose(
                :username,
                as: :username,
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
        end
      end
    end
end
  