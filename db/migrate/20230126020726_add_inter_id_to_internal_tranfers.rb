class AddInterIdToInternalTranfers < ActiveRecord::Migration[5.2]
  def change
    add_column :internal_transfers, :inter_id, :string, limit: 50, null: false, after: :id
    add_index :internal_transfers, :inter_id
  end
end
