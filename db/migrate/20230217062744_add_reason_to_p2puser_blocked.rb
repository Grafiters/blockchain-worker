class AddReasonToP2puserBlocked < ActiveRecord::Migration[5.2]
  def change
    add_column :p2p_user_blockeds, :reason, :text, null: false, after: :target_user_id
  end
end
