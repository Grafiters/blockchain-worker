class ChangeColumnFiatToString < ActiveRecord::Migration[5.2]
  def change
    rename_column :p2p_pairs, :currency_id, :currency
    change_column :p2p_pairs, :fiat_id, :string, limit: 50, null: false, unique: true
    rename_column :p2p_pairs, :fiat_id, :fiat
  end
end
