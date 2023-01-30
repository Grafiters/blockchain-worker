# frozen_string_literal: true

module API
    module V1
      module Market
        module OfferHelpers
          def create_payment_offer(ofid)
              params[:payment].each do |payment|
                  ::P2pOrderPayment.create(payment_params(ofid, payment))
              end
          end
    
          def order_param
            params[:order_by].downcase == 'asc' ? 'id asc' : 'id desc'
          end
        end
      end
    end
end
  