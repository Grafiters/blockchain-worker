module Jobs
    module Cron
        class P2pJobs
            class <<self
                def process
                    Rails.logger.warn "Running Job For P2p Job"

                    first_approvement
                    second_approvement
                    process_to_success
                    sleep 2
                end

                def first_approvement
                    ::P2pOrder.where(state: 'prepare').each do |order|
                        if order.first_approve_expire_at.present? && Time.now >= order.first_approve_expire_at
                            order.update!(state: 'canceled')
                        end
                    end
                end
    
                def second_approvement
                    ::P2pOrder.where(state: 'waiting').each do |order|
                        return if order.second_approve_expire_at.blank?
                        if order.second_approve_expire_at.present? && Time.now >= order.second_approve_expire_at
                            order.update!(state: 'accepted')
                        end
                    end
                end

                def process_to_success
                    ::P2pOrder.where(state: 'accepted').each do |order|
                        return if order.second_approve_expire_at.blank?
                        if order.second_approve_expire_at.present? && Time.now >= order.second_approve_expire_at
                            order.update!(state: 'success')
                        end
                    end
                end
            end
        end
    end
end