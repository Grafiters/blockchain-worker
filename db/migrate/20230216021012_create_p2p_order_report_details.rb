class CreateP2pOrderReportDetails < ActiveRecord::Migration[5.2]
  def change
    create_table :p2p_order_report_details do |t|

      t.timestamps
    end
  end
end
