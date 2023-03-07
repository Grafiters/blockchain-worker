class AddP2pWalletToAccount < ActiveRecord::Migration[5.2]
  def change
    add_column :accounts, :p2p_wallet, :decimal, precision: 32, scale: 16, default: 0, null: false, after: :balance

    Account.update_all("p2p_wallet = 10")
  end
end
