class ChangeColumnUserChatOnP2pChat < ActiveRecord::Migration[5.2]
  def change
    add_column :p2p_chats, :user_uid, :string, limit: 50, null: false
    remove_column :p2p_chats, :p2p_user_id
  end
end
