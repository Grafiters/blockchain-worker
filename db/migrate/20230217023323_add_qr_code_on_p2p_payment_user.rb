class AddQrCodeOnP2pPaymentUser < ActiveRecord::Migration[5.2]
  def change
    change_column :p2p_payment_users, :name, :string, limit: 50, null: true
    add_column :p2p_payment_users, :qrcode, :string, null: true, after: :name
  end
end
