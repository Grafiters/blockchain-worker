class AddUploadFileOnP2pChat < ActiveRecord::Migration[5.2]
  def change
    add_column :p2p_chats, :upload, :text, after: :chat, null: true
    change_column :p2p_chats, :chat, :text, null: true
  end
end
