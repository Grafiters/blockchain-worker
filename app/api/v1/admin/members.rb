# encoding: UTF-8
# frozen_string_literal: true

module API
    module V1
      module Admin
        class Members < Grape::API
          helpers ::API::V2::Admin::Helpers
  
          desc 'Get all members, result is paginated.',
            is_array: true,
            success: API::V2::Admin::Entities::Member
          params do
            optional :email,
                    desc: -> { API::V2::Entities::Member.documentation[:email][:desc] }
            optional :username,
                    desc: -> { API::V2::Entities::Member.documentation[:username][:desc] }
            optional :p2p_name,
                    desc: -> { API::V1::Entities::UserP2p.documentation[:username][:desc] }
            use :uid
          end
          get '/members' do  
            search = P2pUser.joins(:member).order(id: :desc)
                      .tap { |q| q.where!(members: {uid: params[:uid]}) if params[:uid].present? }
                      .tap { |q| q.where!(members: {email: params[:email]}) if params[:email].present? }
                      .tap { |q| q.where!(members: {username: params[:username]}) if params[:username].present? }
                      .tap { |q| q.where!(p2p_users: {username: params[:p2p_name]}) if params[:p2p_name].present? }
                      .tap { |q| present paginate(search), with: API::V1::Entities::UserP2p }
          end

          desc 'Desc Detail Of User Member p2p'
          get '/:uid' do
            present P2pUser.joins(:member).find_by(uid: params[:uid]), with: API::V1::Entities::UserP2p
          end

          desc 'banned user p2p'
          params do
            requires :banned_time,
                   type: { value: Time, message: 'admin.filter.range_from_invalid' },
                   desc: 'An integer represents the seconds elapsed since Unix epoch.'\
                     'If set, only entities FROM the time will be retrieved.'
          end
          post '/:uid/banned' do
            member = P2pUser.joins(:member).find_by(members: { uid: params[:uid]})

            P2pOrder.where('maker_uid = ? OR taker_uid = ?', params[:uid], params[:uid]).each do |order|
              order.update!(state: 'canceled')
              return error!({ errors: ['admin.p2p_order.can_not_send_message_order_is_done'] }, 422) unless order?
            end

            P2pOffer.where(p2p_user_id: member[:id]).each do |offer|
              offer.update!(state: 'canceled')
              return error!({ errors: ['admin.p2p_order.can_not_send_message_order_is_done'] }, 422) unless offer?
            end

            member.update(banned_time: Time.at(params[:banned_time]))
          end
        end
      end
    end
end
