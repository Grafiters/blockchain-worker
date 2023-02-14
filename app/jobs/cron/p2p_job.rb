module Jobs
    module Cron
        class P2pJobs
            class <<self
                def process
                    first_approvement
                    second_approvement
                    sleep 5000000000
                end

                def first_approvement
                    ::P2pOrder.where(state: 'prepare').each do |order|
                        if Time.now >= order.first_approve_expire_at
                            order.update!(state: 'canceled')
                        end
                    end
                end
    
                def second_approvement
                    ::P2pOrder.where(state: 'waiting').each do |order|
                        return if order.second_approve_expire_at.blank?

                        if Time.now >= order.second_approve_expire_at
                            order.update!(state: 'success')
                        end
                    end
                end
            end
        end
    end
end