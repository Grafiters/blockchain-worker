module API
    module V1
        module Account
            class Balance < Grape::API
                namespace :merchants do
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
                    end
                    post '/' do
                        if params[:base_wallet] == params[:target_wallet]
                            error!({ errors: ['balance.account.invalid_target_wallet'] }, 422)
                        end

                        balance = Account.find_by(member_id: current_user[:id], currency_id: params[:currency])

                        return error!({ errors: ['balance.account.balance_not_found'] }, 422) unless balance.present?

                        if balance[:balance] <= 0 || balance[:p2p_balance] <= 0
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
                    end
                end
            end
        end
    end
end