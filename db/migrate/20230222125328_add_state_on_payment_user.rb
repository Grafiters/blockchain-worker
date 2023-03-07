class AddStateOnPaymentUser < ActiveRecord::Migration[5.2]
  def change
    add_column :p2p_payment_users, :state, :integer, limit: 4, default: 0, after: :qrcode

    ::P2pPaymentUser.update_all("state = 0")
  end
end
