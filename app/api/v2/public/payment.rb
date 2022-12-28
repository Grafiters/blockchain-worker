# encoding: UTF-8
# frozen_string_literal: true

module API
  module V2
    module Public
      class Payment < Grape::API
        helpers ::API::V2::Admin::Helpers

        desc 'Payment Confirmations'
        params do
          requires :amount,
                    type: { value: BigDecimal, message: 'account.internal_transfer.non_decimal_amount' }
          requires :bank_code,
                    type: String
          requires :external_id,
                    type: String
          requires :merchant_code,
                    type: String
          requires :account_number,
                    type: String
        end
        post '/payment' do
          token=ENV.fetch('CALLBACK_TOKEN')
          min_amount=ENV.fetch('IDR_DEPOSIT_AMOUNT')
          response  = {}
          if token == request.headers["X-Callback-Token"]
            amount   = params[:amount]
            payment_id   = params[:payment_id]
            external_id   = params[:external_id]

            uid = external_id.split('_')[2]
            member   = Member.find_by(uid: uid)
            if !member
              response[:error_code] = "003"
              response[:error_message] = "UID Not found"
              error!(response, 422)
            end

            if (amount.to_f < min_amount.to_f )
              response[:error_code] = "004"
              response[:error_message] = "Minimum deposit amount is #{min_amount}"
              error!(response, 422)
            end

            record = ::Deposits::Fiat.where(txid:payment_id).first
            if (record)
              response[:error_code] = "005"
              response[:error_message] = "Transaction allready deposited"
              error!(response, 422)
            end
            currency = Currency.find("idr")
            data     = { member: member, currency: currency,amount: amount.to_f,txid: payment_id }
            deposit  = ::Deposits::Fiat.new(data)

            if deposit.save
              deposit.accept!
              {success: true}
            else
              response[:error_code] = "999"
              error!(response, 422)
            end
          else
            {success: false}
          end
        end
      end
    end
  end
end
