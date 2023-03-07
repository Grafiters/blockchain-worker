class AddPaymentUserUidOnP2pPaymentUser < ActiveRecord::Migration[5.2]
  def change
    add_column :p2p_payment_users, :payment_user_uid, :string, limit: 50, null: false, after: :p2p_user_id

    P2pPaymentUser.all.each do |batch|
      payment = P2pPaymentUser.find_by(id: batch[:id])
      payment.update!(payment_user_uid: generate)
    end
  end

  def generate
    uid = "%s%s" % ["P4Y", SecureRandom.hex(5).upcase]
    return uid if P2pPaymentUser.where(payment_user_uid: uid).empty?
  end
end
