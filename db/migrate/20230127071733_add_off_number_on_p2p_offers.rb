class AddOffNumberOnP2pOffers < ActiveRecord::Migration[5.2]
  def change
    add_column :p2p_offers, :offer_number, :string, limit: 75, null: false, after: :id
  end
end
