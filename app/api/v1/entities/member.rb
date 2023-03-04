# encoding: UTF-8
# frozen_string_literal: true

module API
    module V1
      module Entities
        class Member < Base
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
                  } do |member|
                  member.email_data_masking
              end
  
          expose(
            :group,
            documentation: {
              type: String,
              desc: 'Member\'s group.'
            }
          )

          expose(
            :role,
            documentation: {
              type: String,
              desc: 'Member UID.'
            }
          )
        end
      end
    end
  end
  