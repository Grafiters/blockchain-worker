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
                        name: params[:full_name].present? ? params[:full_name] : nil,
                        qrcode: params[:qrcode].present? ? params[:qrcode] : nil
                    }
                end

                def update_params(data)
                    params_mapping = {
                        account_number: params[:account_number].present? ? params[:account_number] : data[:account_number],
                        name: params[:full_name].present? ? params[:full_name] : data[:name],
                        qrcode: params[:qrcode].present? ? params[:qrcode].present? : data[:qrcode]
                    }
                end

                def blocked_params
                    params_mapping = {
                        p2p_user_id: current_p2p_user[:id],
                        target_user_id: target_p2p_user[:id],
                        reason: params[:reason],
                        state: params[:state],
                        state_date: Time.now
                    }
                end

                def p2p_user_feedback
                    user = ::P2pUser.find_by(member_id: current_user[:id])
                    user[:id]
                end

                def exists
                    ::P2pPaymentUser.find_by({p2p_user_id: p2p_user[:id], p2p_payment_id: params[:payment_method]})
                end

                def payment_exists
                    ::P2pPaymentUser.find_by({p2p_payment_id: params[:payment], p2p_user_id: p2p_user[:id]})
                end
            end
        end
    end
end