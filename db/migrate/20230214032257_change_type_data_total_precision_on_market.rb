class ChangeTypeDataTotalPrecisionOnMarket < ActiveRecord::Migration[5.2]
  def change
    change_column :markets, :total_precision, :integer, limit: 4, default: 4
  end
end
