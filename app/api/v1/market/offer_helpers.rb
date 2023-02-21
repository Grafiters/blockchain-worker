# frozen_string_literal: true

module API
    module V1
      module Market
        module OfferHelpers
          def p2p_user_auth
            ::P2pUser.find_by(member_id: current_user[:id])
          end

          def create_payment_offer(ofid)
              params[:payment].each do |index, payment|
                  payment_user = ::P2pPaymentUser.find_by(payment_user_uid: payment)
                  ::P2pOrderPayment.create(payment_params(ofid, payment_user[:id]))
              end
          end

          def check_payment_user
            params[:payment].each do |index, payment|
              check_payment(payment)
            end
          end

          def check_payment(payment_id)
            payment = ::P2pPaymentUser.find_by({payment_user_uid: payment_id, p2p_user_id: p2p_user_id[:id]})

            error!({ errors: ['p2p_user.user.payment_method_users_not_compatible'] }, 422) unless payment.present?
          end
    
          def order_param
            params[:order_by].downcase == 'asc' ? 'id asc' : 'id desc'
          end

          def update_assesment
            if params[:assesment] == 'positif'
                assesment = ::P2pUser.find_by(id: p2p_user_id[:id])

                assesment.increment!(:success_rate)
            end
        end
        end
      end
    end
end