class ChangeTypeColumnWrCodeToTextOnPaymentUserP2p < ActiveRecord::Migration[5.2]
  def change
    change_column :p2p_payment_users, :qrcode, :text, null: true
  end
end
