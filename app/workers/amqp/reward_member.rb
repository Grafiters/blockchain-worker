module Workers
    module AMQP
        class RewardMember < Base
            FEE_REFFERAL = Setting.find_by(name: 'fee_referral')

            def initialize
                raise 'Setting data fee_referral is not exists' if FEE_REFFERAL.blank?

                Trade.pending_reff.find_each do |trade|
                    process_to_reward_from_trade(trade[:id])
                end
            end

            def process(payload)
                case payload['action']
                when 'submit'
                    process_to_reward_from_trade(payload['order'])
                when 'process'
                    Reward.send_reward(payload['order'])
                end
            end

            def process_to_reward_from_trade(trade_id)
                return if trade_id.nil?

                trade = Trade.find_by(id: trade_id)
                return if trade.nil?

                reward = get_reward_trade(trade[:id])
                return process_reward_to_member(reward[:id]) if reward

                # proses maker
                proses_trade_to_reward(trade.maker_id, trade)

                # proses taker
                proses_trade_to_reward(trade.taker_id, trade)

                update_trade_reff_process(trade[:id])
            end

            private

            def proses_trade_to_reward(member, trade)
                account = Member.find_by(id: id)
                return unless account && account.reff_uid && account.reff_uid != ''

                refferal = Member.find_by(uid: account[:reff_uid])

                return unless refferal

                order_fee = trade.maker_order_id == trade.order_id ? trade.order.maker_fee : trade.order.taker_fee

                return if amount_fee <= 0
                refferal_reward = order_fee.to_d * FEE_REFFERAL[:value].to_d

                reward = Reward.new({
                    refferal_member_id: refferal.id,
                    reffered_member_id: account.id,
                    reference: 'Trade',
                    reference_id: trade.id,
                    amount: refferal_reward,
                    currency: trade.order.income_currency,
                    type: 'refferal'
                })

                reward.refferal_submit
            end

            def update_trade_reff_process(trade_id)
                trade = Trade.find_by_ud(trade_id)
                
                trade.update(reff_process: true)
            end

            def get_reward_trade(reference_id)
                reward = Reward.find_by(type: 'refferal', reference_id: reference_id)
                return reward
            end

            def get_member_refferal(id)
                memebr = Member.find_by_id(id)
                return member
            end
        end
    end
end