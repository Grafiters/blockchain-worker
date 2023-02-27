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

            expose :upload,
               documentation: {
                    type: 'String',
                    desc: 'File url and type'
               } do |p2p_chat|
                {
                    url: p2p_chat.verification_url,
                    image: p2p_chat.upload.url
                }
            end

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
  