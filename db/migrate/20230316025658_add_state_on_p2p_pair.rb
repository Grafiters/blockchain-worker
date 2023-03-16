class AddStateOnP2pPair < ActiveRecord::Migration[5.2]
  def change
    add_column :p2p_pairs, :state, :string, default: 'enabled', null: false, after: :maker_fee
  end
end
