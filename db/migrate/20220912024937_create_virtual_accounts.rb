class CreateVirtualAccounts < ActiveRecord::Migration[5.2]
  def change
    create_table :virtual_accounts do |t|
      t.integer   :member_id,     null: false, index: true
      t.string    :currency_id,   limit: 5
      t.string    :bank,          null: false, limit: 64
      t.string    :number,        null: false, limit: 64
      t.string    :name,          null: false, limit: 64
      t.string    :number,        null: false, limit: 64
      t.string    :external_id,   null: true, limit: 64
      t.integer   :merchant_code, null: true
      t.string    :state,         null: false, limit: 64
      t.datetime  :expired,       null: false
      t.timestamps
    end
  end
end
