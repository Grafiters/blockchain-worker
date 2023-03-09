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
            optional :state,
                     desc: 'Filter order by state.'
            optional :role,
                     values: { value: -> { ::Ability.roles }, message: 'admin.member.invalid_role' }
            optional :group,
                     values: { value: -> { ::Member.groups }, message: 'admin.member.invalid_group' }
            optional :email,
                     desc: -> { API::V2::Entities::Member.documentation[:email][:desc] }
            use :uid
            use :date_picker
            use :pagination
            use :ordering
          end
          get '/members' do
            admin_authorize! :read, ::Member
  
            ransack_params = Helpers::RansackBuilder.new(params)
                               .eq(:uid, :email, :state, :role, :group)
                               .with_daterange
                               .build
  
            search = Member.ransack(ransack_params)
            search.sorts = "#{params[:order_by]} #{params[:ordering]}"
            present paginate(search.result), with: API::V2::Admin::Entities::Member
          end
        end
      end
    end
  end
  