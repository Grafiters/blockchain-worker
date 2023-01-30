# encoding: UTF-8
# frozen_string_literal: true

module API
    module V1
        module Account
            module Utils
                extend ::Grape::API::Helpers
                
                def current_p2p_user
                    ::P2pUser.joins(:member).find_by(members: {uid: current_user[:uid]})
                end
            end
        end
    end
end