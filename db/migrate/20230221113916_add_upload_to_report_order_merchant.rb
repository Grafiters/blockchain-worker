class AddUploadToReportOrderMerchant < ActiveRecord::Migration[5.2]
  def change
    add_column :p2p_user_report_details, :upload, :text, null: true, after: :reason
  end
end
