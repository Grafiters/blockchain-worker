class AddColumnStateOnFiat < ActiveRecord::Migration[5.2]
  def change
    add_column :fiats, :state, :integer, limit: 2, null: false, default: 0
  end
end
