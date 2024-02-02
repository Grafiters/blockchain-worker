class Reward < ApplicationRecord
    self.inheritance_column = nil

    extend Enumerize
    STATES = { default: 0, refferal: 100 }.freeze

    enumerize :state, in: type, scope: true

    after_commit on: :update do
        publish_event
    end

    class << self
        def send_reward(id)
            ActiveRecord::Base.transaction do
                reward = find_by_id!(id)

                return unless !reward.is_process
                reward.account.plus_locked_funds(reward.amount)
                
                reward.account.unlock_funds(reward.amount)

                reward.update(is_process: true)
            end
        end
    end

    def refferal
        Member.find_by(id: refferal_member_id)
    end

    def reffered
        Member.find_by(id: reffered_member_id)
    end

    def refferal_submit
        return unless new_record?

        Rails.logger.warn { attributes }
        save!
        AMQP::Queue.enqueue(:reward_member,
                            {action: 'process',
                            order: id},
                            {persistent: false})
    end

    def account
        member = Member.find_by_id(refferal_member_id)

        member.get_account(currency)
    end

    def member_refferal
        member = Member.find_by_id(refferal_member_id)
    end

    private

    def as_json_for_event
        {
            uid: uid,
            refferal_member_id: refferal_member_id,
            reffered_member_id: reffered_member_id,
            reference: reference,
            reference_id: reference_id,
            amount: amount,
            currency: currency,
            type: type,
            is_process: is_process
        }
    end

    def publish_event
        ::AMQP::Queue.enqueue_event("private", member_refferal.uid, "reward", as_json_for_event)
        ::AMQP::Queue.enqueue_event("private", member_refferal.uid, "reward", as_json_for_event)
    end

end
