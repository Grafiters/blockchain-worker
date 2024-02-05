module API
  module V2
    module Account
      class Rewards < Grape::API
        resources :rewards do
          desc 'Get all reward data by refferal',
            success: API::V2::Entities::Reward, is_array: true
          params do
            optional :member_uid,
              type: String,
              desc: "member uid on list of refferal"
            optional :currency,
              type: String,
              values: { value: -> { Currency.visible.pluck(:id) }, message: 'rewards.currency.doesnt_exist' },
              desc: "currency of reward"
            optional :type,
              type: String,
              values: { value: -> { Reward::STATES }, message: 'rewards.refference.invalid_refference' },
              desc: "Refference of reward"
          end
          get do
            refferal_member = nil
            refferal_member = Member.find_by_uid(params[:member_uid]) if params[:member_uid]

            reward = Reward.where(reffered_member_id: current_user.id).order(id: :desc)
            reward = reward.where(refferal_member_id: refferal_member.present? ? refferal_member[:id] : 0 ) if params[:member_uid]
            reward = reward.where(currency: params[:currency]) if params[:currency]
            reward = reward.where(type: params[:type]) if params[:type]
            
            reward_currencies = Reward.where(reffered_member_id: current_user.id)

            summary = {
              total_referal: Member.enabled.where(reff_uid: current_user.uid).count,
              comission: reward.where(reffered_member_id: current_user.id).uniq.count,
              total_reward: reward_currencies.count > 0 ? reward_currencies.sum(:amount) : "0.0",
              data: paginate(API::V2::Entities::Reward.represent(reward))
            }

            present summary
          end
        end
      end
    end
  end
end