class CreateRewards < ActiveRecord::Migration[5.2]
  def change
    create_table :rewards do |t|
      t.string      :uid,                 limit: 75, null: false, :unique => true
      t.integer     :refferal_member_id,  index: true, null: true, desc: 'member of the reffering user'
      t.integer     :reffered_member_id,  index: true, null: true, desc: 'member of the reffered user'
      t.string      :reference,           limit: 150, null: true
      t.integer     :reference_id,        null: true
      t.decimal     :amount,              precision: 32, scale: 16, default: 0, null: false
      t.string      :currency,            limit: 100, index: true, null: false
      t.integer     :type,                default: 0
      t.boolean     :is_process,          default: false

      t.timestamps
    end

    add_column :trades, :reff_process, :boolean, default: false, after: :taker_type
  end

  if Trade.all.count > 0
    Trade.all.each do |trade|
      trade.update(reff_process: true)
    end
  end

end
