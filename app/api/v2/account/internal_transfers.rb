# frozen_string_literal: true

module API
  module V2
    module Account
      class InternalTransfers < Grape::API
        namespace :internal_transfers do
          desc 'List your internal transfers as paginated collection.',
               is_array: true,
               success: API::V2::Entities::InternalTransfer
          params do
            optional :currency,
                     type: String,
                     values: { value: -> { Currency.visible.codes(bothcase: true) }, message: 'account.currency.doesnt_exist' },
                     desc: 'Currency code.'
            optional :state, type: String, desc: 'The state to filter by.'
            optional :time_from,
                   allow_blank: { value: false, message: 'account.internal_tranfer.empty_time_from' },
                   type: { value: Integer, message: 'account.internal_tranfer.non_integer_time_from' },
                   desc: 'An integer represents the seconds elapsed since Unix epoch.'
            optional :time_to,
                   type: { value: Integer, message: 'account.internal_tranfer.non_integer_time_to' },
                   allow_blank: { value: false, message: 'account.internal_tranfer.empty_time_to' },
                   desc: 'An integer represents the seconds elapsed since Unix epoch.'
            optional :ord_type,
                   type: String,
                   values: { value: Order::TYPES, message: 'account.internal_tranfer.invalid_ord_type' },
                   desc: 'Filter order by ord_type.'
            optional :sender
          end

          get do
            user_authorize! :read, ::InternalTransfer

            ransack_params = ::API::V2::Admin::Helpers::RansackBuilder.new(params)
                                                                      .eq(:state)
                                                                      .translate(currency: :currency_id)
                                                                      .merge(g: [
                                                                               { sender_id_eq: current_user.id, receiver_id_eq: current_user.id, m: 'or' }
                                                                             ]).build

            if params[:time_from].present? && params[:time_to].present?
              Rails.logger.warn "-------------------"
              Rails.logger.warn "filter"
              search = InternalTransfer.order(created_at: :desc)
                                    .tap { |q| q.where!('created_at >= ?', Time.at(params[:time_from])) if params[:time_from].present? }
                                    .tap { |q| q.where!('created_at <= ?', Time.at(params[:time_to]+24*60*60)) if params[:time_to].present? }
                                    .ransack(ransack_params)
                                    .result
                                    .order('id desc')
            else
              Rails.logger.warn "-------------------"
              Rails.logger.warn "filter"
              search = InternalTransfer.ransack(ransack_params)
                                     .result
                                     .order('id desc')
            end

            present paginate(search), with: API::V2::Entities::InternalTransfer, current_user: current_user
          end
          desc 'Creates internal transfer.'
          params do
            requires :currency,
                     type: String,
                     values: { value: -> { Currency.visible.codes(bothcase: true) }, message: 'account.currency.doesnt_exist' },
                     desc: 'The currency code.'
            requires :amount,
                     type: { value: BigDecimal, message: 'account.internal_transfer.non_decimal_amount' },
                     values: { value: ->(v) { v.try(:positive?) }, message: 'account.internal_transfer.non_positive_amount' },
                     desc: 'The amount to transfer.'
            requires :otp,
                     type: { value: Integer, message: 'account.internal_transfer.non_integer_otp' },
                     allow_blank: false,
                     desc: 'OTP to perform action'
            requires :username_or_uid,
                     type: String,
                     allow_blank: false,
                     desc: 'Receiver uid or username.'
          end
          post do
            receiver = Member.find_by_username_or_uid(params[:username_or_uid])

            error!({ errors: ['account.internal_transfer.receiver_not_found'] }, 422) if receiver.nil?
            currency = Currency.find(params[:currency])

            unless Vault::TOTP.validate?(current_user.uid, params[:otp])
              error!({ errors: ['account.internal_transfer.invalid_otp'] }, 422)
            end

            if current_user == receiver
              error!({ errors: ['account.internal_transfer.can_not_tranfer_to_yourself'] }, 422)
            end

            internal_transfer = ::InternalTransfer.new(
              currency: currency,
              sender: current_user,
              receiver: receiver,
              amount: params[:amount]
            )
            if internal_transfer.save
              present internal_transfer, with: API::V2::Entities::InternalTransfer
              status 201
            else
              body errors: internal_transfer.errors.full_messages
              status 422
            end

          rescue ::Account::AccountError => e
            report_api_error(e, request)
            error!({ errors: ['account.internal_transfer.insufficient_balance'] }, 422)
          rescue => e
            report_exception(e)
            error!({ errors: ['account.internal_transfer.create_error'] }, 422)
          end

          get '/:code' do
            admin_authorize! :read, ::InternalTransfer
            tranfer = InternalTransfer.find_by(inter_id: params[:code])

            present tranfer, with: API::V2::Entities::InternalTransfer
          end
        end
      end
    end
  end
end
