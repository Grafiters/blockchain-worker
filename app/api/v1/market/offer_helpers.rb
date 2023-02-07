# frozen_string_literal: true

module API
    module V1
      module Market
        module OfferHelpers
          def p2p_user_auth
            ::P2pUser.find_by(member_id: current_user[:id])
          end

          def create_payment_offer(ofid)
              params[:payment].each do |payment|
                  ::P2pOrderPayment.create(payment_params(ofid, payment))
              end
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
  