# encoding: UTF-8
# frozen_string_literal: true

module API
    module V1
      module Entities
        class Report < Base

            expose(
                :order_number,
                as: :order_number,
                documentation: {
                    desc: 'Filter Fiat.',
                    type: String
                }
            )

            expose(
                :created_at,
                :updated_at,
                format_with: :iso8601,
                documentation: {
                    type: String,
                    desc: 'The datetimes for the p2p order.'
                }
            )

            expose :p2p_user_report_detail, as: :detail_report, using: API::V1::Entities::ReportDetail
        end
      end
    end
end
  