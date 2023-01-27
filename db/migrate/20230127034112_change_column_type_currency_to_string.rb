class ChangeColumnTypeCurrencyToString < ActiveRecord::Migration[5.2]
  def change
    change_column :p2p_pairs, :currency_id, :string, limit: 50, null: false
  end
end
