# frozen_string_literal: true

module API
    module V1
      module Public
        class Mount < Grape::API       
          before { set_ets_context! }

          mount API::V1::Public::Fiat
          mount API::V1::Public::Filter
          mount API::V1::Public::Offer
        end
      end
    end
  end
  