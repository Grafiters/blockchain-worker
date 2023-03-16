class AddTotalPrecisionToMarkets < ActiveRecord::Migration[5.2]
  def change
    # add_column :markets, :total_precision, :decimal, default: 0, precision: 32, scale: 16, after: :price_precision
  end
end
