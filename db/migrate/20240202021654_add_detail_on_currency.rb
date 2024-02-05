class AddDetailOnCurrency < ActiveRecord::Migration[5.2]
  def change
    add_column :currencies, :detail_currencies, :text, null: true, after: :price
    add_column :currencies, :market_cap, :decimal, precision: 32, scale: 16, default: 0, after: :detail_currencies
    add_column :currencies, :total_supply, :integer, default: 0, after: :market_cap, null: true
    add_column :currencies, :circulation_supply, :integer, default: 0, after: :total_supply, null: true
    add_column :currencies, :options, :json, after: :circulation_supply, null: true

    add_column :blockchains, :blockchain_group, :integer, default: 0
  end
end
