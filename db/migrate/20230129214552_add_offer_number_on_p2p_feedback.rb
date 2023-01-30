class AddOfferNumberOnP2pFeedback < ActiveRecord::Migration[5.2]
  def change
    add_column :p2p_order_feedbacks, :order_number, :string, limit: 50, null: false
  end
end
