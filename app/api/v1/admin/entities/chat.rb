# encoding: UTF-8
# frozen_string_literal: true

module API
    module V1
      module Admin
        module Entities
            class Chat < Grape::Entity
                format_with(:iso8601) {|t| t.to_time.in_time_zone(Rails.configuration.time_zone).iso8601 if t }
                
                expose :member, with: API::V1::Admin::Entities::Member
    
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
                        image: p2p_chat.upload
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
end
  