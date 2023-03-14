# encoding: UTF-8
# frozen_string_literal: true

module API
    module V1
        module Admin
            module ParamHelpers
                extend ::Grape::API::Helpers
                
                def chat_params(order)
                    params_mapping = {
                        p2p_order_id: order[:id],
                        user_uid: current_user[:uid],
                        chat: image_check,
                        upload: image_exists
                    }
                end

                def image_check
                    params[:message]['tempfile'].blank? ? params[:message] : nil
                end

                def image_exists
                    params[:message]['tempfile'].present? ? params[:message]['tempfile'] : nil
                end

                def validate_fiat
                    if params[:name].present? && params[:code].present?
                        fiat = ::Fiat.find_by(name: params[:name], code: params[:code])
                        error!({ errors: ['account.users.username_limit_change'] }, 422) unless fiat.blank?
                    end
                end
            end
        end
    end
end