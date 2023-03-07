class ChangeColumnTipeOnP2pPaymentToInteger < ActiveRecord::Migration[5.2]
  def change
    P2pPayment.update_all("tipe = 100")

    change_column :p2p_payments, :tipe, :integer, limit: 4
  end
end
