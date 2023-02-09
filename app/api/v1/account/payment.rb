module API
    module V1
        module Account
            class Payment < Grape::API
                namespace :payment do
                    helpers ::API::V2::Admin::Helpers
                    helpers ::API::V1::Account::ParamHelpers

                    desc 'Get available fiat'
                    get "/" do
                        p2p_user = ::P2pUser.joins(:member).find_by(members: {uid: current_user[:uid]})

                        # present ::P2pPaymentUser.joins(:p2p_payment).select("p2p_payment_users.*", "p2p_payments.*").where(p2p_payment_users: {p2p_user_id: p2p_user[:id]})
                        present paginate(
                                ::P2pPaymentUser.joins(:p2p_payment).select("p2p_payment_users.*", "p2p_payments.*").where(p2p_payment_users: {p2p_user_id: p2p_user[:id]})
                            )
                    end

                    desc 'Create new payment method for user p2p'
                    params do
                        requires :payment_method,
                                type: Integer
                        requires :account_number,
                                type: String
                        requires :full_name,
                                type: String
                    end
                    post do
                        if exists.present?
                            error!({ errors: ['p2p_user.payment_user.payment_user_is_exists'] }, 422)
                        end
                        
                        payment = ::P2pPaymentUser.create(build_params)

                        present payment
                    end

                    post "/update/:payment" do
                        if payment_exists.blank?
                            error!({ errors: ['p2p_user.payment_user.payment_user_does_not_exists'] }, 422)
                        end

                        payement = ::P2pPaymentUser.find_by(id: params[:payment])

                        payment = payement.update(update_params(payement))

                        present :succes, ['p2p_user.payment_user.updated']
                    end
                end
            end
        end
    end
end