class ChangeNameP2pWalletToP2pBalance < ActiveRecord::Migration[5.2]
  def change
    rename_column :accounts, :p2p_wallet, :p2p_balance
    add_column :accounts, :p2p_locked, :decimal, precision: 32, scale: 18, default: 0, null: false, after: :p2p_balance
  end
end
