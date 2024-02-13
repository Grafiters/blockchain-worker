class AddBlockchainKeyOnSpesificFolder < ActiveRecord::Migration[5.2]
  def change
    add_column :payment_address, :blockchain_key, :string, limit: 32, after: :id
    add_column :withdraws, :blockchain_key, :string, limit: 32, after: :id
    add_column :deposits, :blockchain_key, :string, limit: 32, after: :id
  end
end
