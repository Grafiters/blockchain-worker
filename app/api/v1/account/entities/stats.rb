# encoding: UTF-8
# frozen_string_literal: true

module API
    module V1
        module Account
            module Entities
                class Stats < API::V1::Entities::UserWithMember
                    expose :positif_feedback,
                            documentation: {
                                desc: 'Order Number.',
                                type: String
                            } do |p2p_user|
                                p2p_user.positif_feedback
                            end
                    
                    expose :trade,
                            documentation: {
                                desc: 'Order Number.',
                                type: String
                            } do |p2p_user|
                                p2p_user.trade
                            end
                end
            end
        end
    end
end
  