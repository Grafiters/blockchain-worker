# frozen_string_literal: true

module API
    module V1
      module Market
        class Mount < Grape::API

          before { authenticate! }
          before { set_ets_context! }

          mount API::V1::Market::Offer
          mount API::V1::Market::Order
          mount API::V1::Market::Feedback
        end
      end
    end
end
  