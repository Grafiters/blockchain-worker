# encoding: UTF-8
# frozen_string_literal: true

module API
    module V1
      module Market
        module NamedParams
          extend ::Grape::API::Helpers

          params :offer do
            # requires :currency,
            #          type: String,
            #         #  values: { value: -> { ::Market.spot.active.pluck(:symbol) }, message: 'market.spot_market.doesnt_exist_or_not_enabled' },
            #         #  desc: -> { V2::Entities::Market.documentation[:symbol] }
            # requires :fiat,
            #           type: String,
            #           value: { value: -> { ::Fiat.find_by(name: params[:fiat]) } }
            # requires :
          end
        end
      end
    end
end
  