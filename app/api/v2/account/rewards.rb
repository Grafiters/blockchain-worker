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

              current_user.rewards.order(id: :desc)
                .tap { |q| q.where!(refferal_member_id: refferal_member.present? ? refferal_member[:id] : 0 ) if params[:member_uid] }
                .tap { |q| q.where!(currency: params[:currency]) if params[:currency] }
                .tap { |q| q.where!(type: params[:type]) if params[:type] }
                .tap { |q| present paginate(q), with: API::V2::Entities::Reward }
            end
          end
        end
    end
end