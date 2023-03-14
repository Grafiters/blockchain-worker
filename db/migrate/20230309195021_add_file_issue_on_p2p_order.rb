class AddFileIssueOnP2pOrder < ActiveRecord::Migration[5.2]
  def change
    add_column :p2p_orders, :is_issue, :integer, :null => false, :default => false
  end
end
