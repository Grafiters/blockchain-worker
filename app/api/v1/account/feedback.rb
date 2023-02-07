module API
    module V1
        module Account
            class Feedback < Grape::API
                helpers ::API::V1::Admin::Helpers

                # after_save :update_assesment

                namespace :feedback do
                    desc 'desc all Feedback on Order'
                    get do
                        present paginate(Rails.cache.fetch("trading_fees_#{params}", expires_in: 600) { 
                            ::P2pOrderFeedback.joins(p2p_order: :p2p_offer).where(p2p_offers: {p2p_user_id: p2p_user[:id]})
                         })
                    end
                end
            end
        end
    end
end