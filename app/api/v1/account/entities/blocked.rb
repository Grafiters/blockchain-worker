# encoding: UTF-8
# frozen_string_literal: true

module API
    module V1
        module Account
            module Entities
                class Blocked < Grape::Entity
                    expose(
                        :reason,
                        documentation: {
                            type: String,
                            desc: 'Member UID.'
                        }
                    )
            
                    expose :state,
                        documentation: {
                            type: String,
                            desc: 'Member email.'
                        }
            
                    expose :p2p_user, using: API::V1::Entities::UserWithMember
                    expose :target_user, using: API::V1::Entities::UserWithMember
                end
            end
        end
    end
end