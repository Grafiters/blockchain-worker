# encoding: UTF-8
# frozen_string_literal: true

module API
    module V1
      module Account
        module Entities
            class PaymentFeedback < Grape::Entity
                expose(
                    :name,
                    as: :bank_name,
                    documentation: {
                        desc: 'Filter Fiat.',
                        type: String
                    }
                )
    
                expose(
                    :symbol,
                    as: :symbol,
                    documentation: {
                        desc: 'Filter Fiat.',
                        type: String
                    }
                )
                expose(
                    :logo_url,
                    as: :logo,
                    documentation: {
                        desc: 'Filter Fiat.',
                        type: String
                    }
                )

                expose(
                    :base_color,
                    as: :base_color,
                    documentation: {
                        desc: 'Filter Fiat.',
                        type: String
                    }
                )
    
                expose(
                    :state,
                    as: :state,
                    documentation: {
                        desc: 'Filter Fiat.',
                        type: String
                    }
                )

                expose(
                    :tipe,
                    as: :tipe,
                    documentation: {
                        desc: 'Filter Fiat.',
                        type: String
                    }
                    ) do |payment|
                        tipe_bank(payment)
                    end

                
                def tipe_bank(payment)
                    payment.tipe == 100 ? 'bank' : 'ewallet'
                end
            end
          end
        end
    end
end
  