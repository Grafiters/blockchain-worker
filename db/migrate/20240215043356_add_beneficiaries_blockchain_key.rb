class AddBeneficiariesBlockchainKey < ActiveRecord::Migration[5.2]
  def change
    add_column :beneficiaries, :blockchain_key, :string, limit: 32, after: :id, null: false
  end
end
