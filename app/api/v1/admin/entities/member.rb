# encoding: UTF-8
# frozen_string_literal: true

module API
    module V1
        module Admin
            module Entities
                class Member < Grape::Entity
                    expose(
                        :uid,
                        documentation: {
                            type: String,
                            desc: 'Member UID.'
                        }
                    )
            
                    expose :email,
                        documentation: {
                            type: String,
                            desc: 'Member email.'
                        }
            
                    expose(
                        :group,
                        documentation: {
                            type: String,
                            desc: 'Member\'s group.'
                        }
                    )
                end
            end
        end
    end
end
  