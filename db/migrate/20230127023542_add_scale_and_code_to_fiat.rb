class AddScaleAndCodeToFiat < ActiveRecord::Migration[5.2]
  def change
    add_column :fiats, :scale, :integer, null: false, after: :symbol
    add_column :fiats, :code, :string,  limit: 15, null: false, unique: true, after: :scale
  end
end
