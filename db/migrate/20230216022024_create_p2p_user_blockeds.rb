class CreateP2pUserBlockeds < ActiveRecord::Migration[5.2]
  def change
    create_table :p2p_user_blockeds do |t|
      t.integer   "p2p_user_id",    limit: 4
      t.integer   "target_user_id", limit: 4
      t.integer   "state",          limit: 4
      t.datetime  "state_date"

      t.timestamps
    end
  end
end
