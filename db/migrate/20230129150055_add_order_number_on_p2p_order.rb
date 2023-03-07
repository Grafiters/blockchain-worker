class AddOrderNumberOnP2pOrder < ActiveRecord::Migration[5.2]
  def change
    add_column :p2p_orders, :order_number, :string,limit: 50, null: false, after: :id
  end
end
