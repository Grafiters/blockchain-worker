module API
    module V1
        module Account
            class Balance < Grape::API
                namespace :balances do
                    helpers ::API::V2::Admin::Helpers
                    helpers ::API::V1::Account::Utils
                    helpers ::API::V1::Account::ParamHelpers

                    desc 'tranfer asset from base wallet to another wallet'
                    params do
                        requires :base_wallet,
                                type: String,
                                allow_blank: false,
                                values: { value: %w(spot p2p),message: 'p2p_account.order.non_state_params' }
                        requires :target_wallet,
                                type: String,
                                allow_blank: false,
                                values: { value: %w(spot p2p),message: 'p2p_account.order.non_state_params' }
                        requires :currency,
                                type: String,
                                allow_blank: false,
                                desc: -> { V1::Entities::Fiat.documentation[:currency] }
                        requires :amount,
                                allow_blank: false,
                                type: {value: BigDecimal, message: 'balance.account.non_decimal_amount'}
                        requires :otp_code,
                                type: { value: Integer, message: 'p2p_user.payment.non_integer_otp' },
                                allow_blank: true,
                                desc: 'OTP to perform action'
                    end
                    post '/' do
                        if params[:base_wallet] == params[:target_wallet]
                            error!({ errors: ['balance.account.invalid_target_wallet'] }, 422)
                        end

                        unless Vault::TOTP.validate?(current_user.uid, params[:otp_code])
                            error!({ errors: ['p2p_user.payment.invalid_otp'] }, 422)
                        end

                        balance = ::Account.find_by(member_id: current_user[:id], currency_id: params[:currency])

                        return error!({ errors: ['balance.account.balance_not_found'] }, 422) unless balance.present?

                        
                        if params[:base_wallet] == 'spot' && balance[:balance] <= 0
                            error!({ errors: ['balance.account.insuffient_balance'] }, 422)
                        end

                        if params[:base_wallet] == 'p2p' && balance[:p2p_balance] <= 0
                            error!({ errors: ['balance.account.insuffient_balance'] }, 422)
                        end

                        if params[:base_wallet] == 'spot'
                            balance.update({
                                balance: balance[:balance] - params[:amount],
                                p2p_balance: balance[:p2p_balance] + params[:amount]
                            })
                        elsif params[:base_wallet] == 'p2p'
                            balance.update({
                                balance: balance[:balance] + params[:amount],
                                p2p_balance: balance[:p2p_balance] - params[:amount]
                            })
                        end

                        error!(balance.errors.details, 422) unless balance.save
                    end
                end
            end
        end
    end
end