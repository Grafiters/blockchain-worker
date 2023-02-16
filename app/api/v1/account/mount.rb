# frozen_string_literal: true

module API
    module V1
      module Account
        class Mount < Grape::API       
          before { set_ets_context! }

          mount API::V1::Account::Merchant
          mount API::V1::Account::Payment
          mount API::V1::Account::Order
          mount API::V1::Account::User
        end
      end
    end
  end
  