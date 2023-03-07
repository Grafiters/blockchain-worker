class AddColorCodeToP2pPayment < ActiveRecord::Migration[5.2]
  def change
    add_column :p2p_payments, :base_color, :string, limit: 50, null: true, after: :logo_url
  end
end
