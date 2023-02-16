class CreateP2pUserReports < ActiveRecord::Migration[5.2]
  def change
    create_table :p2p_user_reports do |t|
      t.integer   "p2p_user_id", limit: 4
      t.string    "order_number", limit: 50, null: true
      t.integer   "state",  limit: 4, default: 0

      t.timestamps
    end
    add_index "p2p_user_reports", ["p2p_user_id"], name: "index_p2p_user_on_p2p_user_reports", using: :btree

    create_table :p2p_user_report_details do |t|
      t.integer   "p2p_user_report_id", limit: 4
      t.string    "key",                limit: 50
      t.text      "reason"

      t.timestamps
    end

    add_index "p2p_user_report_details", ["p2p_user_report_id"], name: "index_p2p_user_reports_on_p2p_user_report_details", using: :btree
  end
end
