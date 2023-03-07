class AddP2pUserIdOnP2pOrder < ActiveRecord::Migration[5.2]
  def change
    add_column :p2p_orders, :p2p_user_id, :integer, null: false

    add_index "p2p_orders", ["p2p_user_id"], name: "index_p2p_orders_on_p2p_user_id", using: :btree
  end
end
