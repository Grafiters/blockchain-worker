# encoding: UTF-8
# frozen_string_literal: true

module API
    module V1
      module Entities
        class PaymentUser < Base
            expose(
                :payment_user_uid,
                as: :payment_user_uid,
                documentation: {
                    desc: 'Filter Fiat.',
                    type: String
                }
            )

            expose :bank,
                documentation: {
                    desc: 'Filter Fiat.',
                    type: String
                } do |p2p_payment_user|
                    p2p_payment_user.payment_method[:name]
                end

            expose(
                :name,
                as: :account_name,
                documentation: {
                    desc: 'Filter Fiat.',
                    type: String
                }
            )

            expose(
                :account_number,
                as: :account_number,
                documentation: {
                    desc: 'Filter Fiat.',
                    type: String
                }
            )

            expose :logo,
                documentation: {
                    desc: 'Filter Fiat.',
                    type: String
                } do |p2p_payment_user|
                    p2p_payment_user.payment_method[:logo_url]
                end

            expose :base_color,
                documentation: {
                    desc: 'Filter Fiat.',
                    type: String
                } do |p2p_payment_user|
                p2p_payment_user.payment_method[:base_color]
            end

            expose :qrcode,
                documentation: {
                    type: 'String',
                    desc: 'File url and type'
            } do |p2p_payment_user|
                p2p_payment_user.qrcode
            end

            expose(
                :state,
                as: :state,
                documentation: {
                    desc: 'Filter Fiat.',
                    type: String
                }
            )
        end
      end
    end
end
  