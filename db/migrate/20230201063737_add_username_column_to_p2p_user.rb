class AddUsernameColumnToP2pUser < ActiveRecord::Migration[5.2]
  def change
    add_column :p2p_users, :username, :string, limit: 50, null: true
  end
end
