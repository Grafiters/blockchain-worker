class ChangeOrderPaymentToOfferPayment < ActiveRecord::Migration[5.2]
  def change
    rename_table :p2p_order_payments, :p2p_offer_payments

    rename_column :p2p_orders, :p2p_order_payment_id, :p2p_payment_user_id
  end
end
