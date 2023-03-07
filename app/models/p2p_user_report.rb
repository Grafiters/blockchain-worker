class P2pUserReport < ApplicationRecord
    has_many :p2p_user_report_detail, class_name: "P2pUserReportDetail", foreign_key: :p2p_user_report_id, primary_key: :id

    belongs_to :p2p_user, class_name: "P2pUser", foreign_key: :p2p_user_id, primary_key: :id

end
