class AddColumnTocAutoReplayLimitTimeToP2pOffer < ActiveRecord::Migration[5.2]
  def change
    add_column  :p2p_offers, :paymen_limit_time, :string, null: false
    add_column  :p2p_offers, :term_of_condition, :text, null: true
    add_column  :p2p_offers, :auto_replay,  :string, limit: 150, null: true
  end
end
