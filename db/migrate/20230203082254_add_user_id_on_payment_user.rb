class AddUserIdOnPaymentUser < ActiveRecord::Migration[5.2]
  def change
    add_column :p2p_payment_users, :p2p_user_id, :integer, index: true, null: false, after: :p2p_payment_id
  end
end
