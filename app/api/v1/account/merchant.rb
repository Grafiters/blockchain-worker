module API
    module V1
        module Account
            class Merchant < Grape::API
                namespace :merchants do
                    helpers ::API::V2::Admin::Helpers
                    helpers ::API::V1::Account::Utils
                    helpers ::API::V1::Account::ParamHelpers

                    desc 'Blocked Merchant'
                    params do
                        requires :state,
                                type: String,
                                desc: 'State requires blocked & unblocked'
                        optional :reason,
                                type: String,
                                desc: 'Reason of blocked merchant'
                    end
                    put 'blocked/:merchant' do

                        if target_p2p_user[:uid] == current_user[:uid]
                            error!({ errors: ['p2p_order.merchant.blocked.cannot_block_yuorself'] }, 422)
                        end

                        target = ::P2pUserBlocked.find_by(target_user_id: target_p2p_user[:id], p2p_user_id: current_p2p_user[:id])

                        if target.blank?
                            blocked = ::P2pUserBlocked.create!(blocked_params)
                        else
                            blocked = target.update!(state: params[:state])
                        end

                        present blocked
                    end
                end
            end
        end
    end
end