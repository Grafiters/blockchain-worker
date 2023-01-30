# encoding: UTF-8
# frozen_string_literal: true

module API
    module V1
        module Account
            module ParamHelpers
                extend ::Grape::API::Helpers
                
                def build_params
                    params_mapping = {
                        p2p_payment_id: params[:payment_method],
                        account_number: params[:account_number],
                        name: params[:full_name]
                    }
                end
            end
        end
    end
end