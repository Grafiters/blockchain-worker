module API
    module V1
        module Account
            class User < Grape::API
                namespace :users do
                    helpers ::API::V2::Admin::Helpers
                    helpers ::API::V1::Account::ParamHelpers
                    helpers ::API::V1::Account::Utils

                    desc 'Get User P2p'
                    get "/" do
                        user_authorize! :read, ::P2pUser
                        member = ::P2pUser.joins(:member).find_by(members: {uid: current_user[:uid]})

                        if member.blank?
                            member = p2p_user
                        end

                        present member, with: API::V1::Account::Entities::Stats, masking: true
                    end

                    desc 'Create new payment method for user p2p'
                    params do
                        requires :username,
                                type: String,
                                desc: 'new username from p2p user'
                    end
                    post do
                        user = ::P2pUser.find_by(member_id: current_user[:id])
                        date = (Time.now - user.updated_at) / 86400

                        # if date < 356 && user[:updated_at] != user[:created_at]
                        #     error!({ errors: ['account.users.username_limit_change'] }, 422)
                        # end

                        user.update(username: params[:username])

                        present ::P2pUser.joins(:member).find_by(members: {uid: current_user[:uid]}), with: API::V1::Entities::UserWithMember, masking: true
                    end

                    desc 'Get Feedback from another user'
                    params do
                        optional :assesment,
                                type: String,
                                values: { value: %w(positive negative), message: 'feedback.users.invalid_assesment' }
                    end
                    get '/feedback' do
                        feedback = ::P2pOrderFeedback.joins(p2p_order: :p2p_offer)
                                            .select("p2p_order_feedbacks.*", "p2p_orders.p2p_order_payment_id as payment", "p2p_orders.p2p_user_id as member",
                                            "p2p_orders.created_at as p2p_start","p2p_orders.updated_at as p2p_end", "p2p_orders.first_approve_expire_at as payment_limit")
                                            .where(p2p_offers: {p2p_user_id: p2p_user_feedback})

                        feedback.each do |feed |
                            feed[:payment] = payments(feed[:payment])
                            feed[:member] = buyorsel(feed[:member])
                            feed[:payment_limit]   = count_time_limit(feed[:p2p_start], feed[:p2p_end])
                        end

                        present feedback, with: API::V1::Entities::Feedback
                    end
                    
                    get '/blocked' do
                        blocked = ::P2pUserBlocked.joins(:p2p_user).where(p2p_users: {id: current_p2p_user[:id]})

                        present blocked
                    end
                end
            end
        end
    end
end