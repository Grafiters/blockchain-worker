module API
    module V1
        module Account
            class Feedback < Grape::API
                helpers ::API::V1::Account::ParamHelpers

                # after_save :update_assesment

                namespace :feedback do
                    desc 'desc all Feedback on Order'
                    get do
                        present ::P2pOrder.joins(:p2p_order_feedback).select("p2p_order_feedbacks.*").where(p2p_orders: {p2p_user_id: p2p_user[:id]})
                    end
                end
            end
        end
    end
end