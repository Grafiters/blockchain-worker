namespace :p2pjob do
    namespace :order do
        desc 'Validate state prepare to waiting by first approve time.'
        task prepare: :environment do
            Job.execute('first_approvement') do
                orders = ::P2pOrder.where('first_approve_expire_at <= ? AND state = ?', Time.now, "prepare")
                orders.each do |o|
                    ::P2pOrder.submit(o.id)
                end

                { pointer: Time.now.to_s(:db), counter: orders.count }
            end
        end
    end
end