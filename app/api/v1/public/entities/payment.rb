# encoding: UTF-8
# frozen_string_literal: true

module API
    module V1
      module Public
        module Entities
            class Payment < Grape::Entity
                expose(
                    :id,
                    as: :id,
                    documentation: {
                        desc: 'Filter Fiat.',
                        type: String
                    }
                )
    
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
                    :tipe,
                    as: :type,
                    documentation: {
                        desc: 'Type Payment.',
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
            end
        end
      end
    end
end
  