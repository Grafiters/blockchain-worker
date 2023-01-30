class AddTakerMakerOnP2pOrder < ActiveRecord::Migration[5.2]
  def change
      remove_column :p2p_orders, :p2p_user_id

      add_column :p2p_orders, :maker_uid, :string, limit: 25, null: false, after: :p2p_offer_id
      add_column :p2p_orders, :taker_uid, :string, limit: 25, null: false, after: :maker_uid
      add_column :p2p_orders, :maker_fee, :decimal, precision: 17, scale: 16
      add_column :p2p_orders, :taker_fee, :decimal, precision: 17, scale: 16
    
  end
end
