module API
    module V1
        module Account
            class Payment < Grape::API
                namespace :payment do
                    helpers ::API::V2::Admin::Helpers
                    helpers ::API::V1::Account::ParamHelpers
                    helpers ::API::V1::Account::Utils

                    desc 'Get available fiat'
                    get "/" do
                        p2p_user = ::P2pUser.joins(:member).find_by(members: {uid: current_user[:uid]})

                        # present ::P2pPaymentUser.joins(:p2p_payment).select("p2p_payment_users.*", "p2p_payments.*").where(p2p_payment_users: {p2p_user_id: p2p_user[:id]})
                        present paginate(
                                ::P2pPaymentUser.joins(:p2p_payment).select("p2p_payment_users.id","p2p_payment_users.payment_user_uid","p2p_payment_users.name as account_name", "p2p_payment_users.account_number","p2p_payment_users.qrcode", "p2p_payments.symbol", "p2p_payments.logo_url","p2p_payments.base_color","p2p_payments.state","p2p_payments.name").where(p2p_payment_users: {p2p_user_id: p2p_user[:id]})
                            ), with: API::V1::Account::Entities::Payment
                    end

                    desc 'Create new payment method for user p2p'
                    params do
                        requires :payment_method,
                                type: Integer
                        requires :account_number,
                                type: String
                        optional :full_name,
                                type: String
                        optional :qrcode
                        optional :otp,
                                type: { value: Integer, message: 'p2p_user.payment.non_integer_otp' },
                                allow_blank: true,
                                desc: 'OTP to perform action'
                    end
                    post do
                        if exists.present?
                            error!({ errors: ['p2p_user.payment_user.payment_user_is_exists'] }, 422)
                        end

                        if params[:otp].present?
                            unless Vault::TOTP.validate?(current_user.uid, params[:otp])
                                error!({ errors: ['p2p_user.payment.invalid_otp'] }, 422)
                            end
                        end

                        payment = ::P2pPaymentUser.create(build_params)

                        present payment
                    end

                    get "/:symbol" do
                        if params[:symbol].blank?
                            errors!({errors: ["2pp_user.payment_user.payment_method_invalid_data"]}, 422)
                        end

                        name = params[:symbol].split("-")
                        if name.length > 1
                            bank_name = ::P2pPayment.find_by(symbol: namejoin(" "))
                        else
                            bank_name = ::P2pPayment.find_by(symbol: params[:symbol])
                        end

                        if bank_name.blank?
                            error!({ errors: ['p2p_user.payment_user.payment_method_invalid_params'] }, 422)
                        end
                        present bank_name
                    end

                    desc 'update payment user by slug payment user uid'
                    params do
                        optional :account_number,
                                type: String
                        optional :full_name,
                                type: String
                        optional :qrcode
                    end
                    post "/update/:payment" do
                        payment = ::P2pPaymentUser.find_by(payment_user_uid: params[:payment])
                        
                        if payment.blank?
                            error!({ errors: ['p2p_user.payment_user.payment_user_does_not_exists'] }, 422)
                        end

                        payment.update(update_params(payment))
                        
                        present payment
                        # payment = payment.update(update_params(payment))

                        # present :succes, ['p2p_user.payment_user.updated']
                    end
                end
            end
        end
    end
end