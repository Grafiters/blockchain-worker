class P2pUserReportDetail < ApplicationRecord
    belongs_to :p2p_user_report, class_name: :p2p_user_report, foreign_key: :p2p_user_report_id, primary_key: :id
end
