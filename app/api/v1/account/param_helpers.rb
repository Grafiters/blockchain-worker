# encoding: UTF-8
# frozen_string_literal: true

module API
    module V1
        module Account
            module ParamHelpers
                extend ::Grape::API::Helpers
                
                def build_params
                    params_mapping = {
                        p2p_user_id: p2p_user[:id],
                        p2p_payment_id: params[:payment_method],
                        account_number: params[:account_number],
                        name: params[:full_name]
                    }
                end

                def p2p_user
                    ::P2pUser.find_by(member_id: current_user[:id])
                end

                def exists
                    ::P2pPaymentUser.find_by({p2p_user_id: p2p_user[:id], p2p_payment_id: params[:payment_method]})
                end
            end
        end
    end
end