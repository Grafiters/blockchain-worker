# encoding: UTF-8
# frozen_string_literal: true

module API
    module V1
      module Entities
        class Chat < Base
            expose :p2p_user, with: API::V1::Entities::UserP2p

            expose(
                :chat,
                as: :chat,
                documentation: {
                    desc: 'Filter Fiat.',
                    type: String
                }
            )

            expose(
                :chat,
                as: :chat,
                documentation: {
                    desc: 'Filter Fiat.',
                    type: String
                }
            )

            expose(
                :created_at,
                :updated_at,
                format_with: :iso8601,
                documentation: {
                    type: String,
                    desc: 'The datetimes for the p2p order.'
                }
            )
        end
      end
    end
end
  