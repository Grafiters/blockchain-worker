class ChangeDataTypeTextToLongText < ActiveRecord::Migration[5.2]
  def change
    change_column :p2p_chats, :upload, :longtext
    change_column :p2p_payment_users, :qrcode, :longtext
    change_column :p2p_user_report_details, :upload, :longtext
  end
end
