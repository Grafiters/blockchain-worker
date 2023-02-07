class CreateP2PTable < ActiveRecord::Migration[4.2]
  def up
    create_table  "fiats", force: :cascade do |t|
      t.string    "name",      limit: 50,  null: false
      t.string    "symbol",    limit: 50,  null: false
      t.string    "symbol",    limit: 25,  null: false
      t.string    "icon_url",              null: false
      t.decimal   "taker_fee",             precision: 32, scale: 16
      t.decimal   "maker_fee",             precision: 32, scale: 16
      t.datetime  "created_at"
      t.datetime  "updated_at"
    end
    
    create_table  "p2p_settings", force: :cascade do |t|
      t.string    "name",      limit: 50, null: false
      t.string    "value",     limit: 50, null: false
      t.string    "type",      limit: 50, null:false
      t.string    "comment",   limit: 50, null: true
      t.datetime  "created_at"
      t.datetime  "updated_at"
    end

    create_table  "p2p_users", force: :cascade do |t|
      t.integer   "member_id",      limit: 4
      t.string    "logo",           limit: 50, null: true
      t.integer   "offers_count",              default: 0
      t.integer   "success_rate",              default: 0
      t.boolean   "banned_state",              default: false
      t.datetime  "banned_time"
      t.datetime  "created_at"
      t.datetime  "updated_at"
    end
    add_index "p2p_users", ["member_id"], name: "index_p2p_users_on_member_id", using: :btree

    create_table  "p2p_payments", force: :cascade do |t|
      t.integer   "fiat_id",   limit: 4,    null: false
      t.string    "name",      limit: 50,   null: false
      t.string    "symbol",    limit: 50,   null: false
      t.string    "logo_url",  limit: 256,   null: false
      t.string    "state",     limit: 10,   null: false
      t.string    "tipe",      limit: 50,   null: false
      t.datetime  "deleted_at"
      t.datetime  "created_at"
      t.datetime  "updated_at"
    end
    add_index "p2p_payments", ["fiat_id"], name: "index_p2p_payments_on_member_id", using: :btree

    create_table  "p2p_pairs", force: :cascade do |t|
      t.integer   "fiat_id",      limit: 4,   null: false
      t.integer   "currency_id",  limit: 4,   null: false
      t.decimal   "taker_fee",                precision: 32, scale: 16
      t.decimal   "maker_fee",                precision: 32, scale: 16
      t.datetime  "created_at"
      t.datetime  "updated_at"
    end
    add_index "p2p_pairs", ["fiat_id"], name: "index_p2p_pairs_on_fiat_id", using: :btree
    add_index "p2p_pairs", ["currency_id"], name: "index_p2p_pairs_on_currency_id", using: :btree

    create_table  "p2p_payment_users", force: :cascade do |t|
      t.integer   "p2p_payment_id",   limit: 4,   null: false
      t.string    "account_number",   limit: 50,  null: false
      t.string    "name",             limit: 50,  null: false
      t.datetime  "created_at"
      t.datetime  "updated_at"
    end
    add_index "p2p_payment_users", ["p2p_payment_id"], name: "index_p2p_payment_users_on_p2p_payment_id", using: :btree

    create_table  "p2p_offers", force: :cascade do |t|
      t.integer   "p2p_user_id",    limit: 4
      t.integer   "p2p_pair_id",    limit: 4
      t.decimal   "origin_amount",          precision: 32, scale: 16
      t.decimal   "available_amount",       precision: 32, scale: 16
      t.decimal   "price",                  precision: 32, scale: 16
      t.decimal   "min_order_amount",       precision: 32, scale: 16
      t.decimal   "max_order_amount",       precision: 32, scale: 16
      t.string    "state",          limit: 15, default: "pending"
      t.string    "side",           limit: 10, null: false
      t.datetime  "created_at"
      t.datetime  "updated_at"
    end
    add_index "p2p_offers", ["p2p_user_id"], name: "index_p2p_offers_on_p2p_user_id", using: :btree
    add_index "p2p_offers", ["p2p_pair_id"], name: "index_p2p_offers_on_p2p_pair_id", using: :btree

    create_table  "p2p_order_payments", force: :cascade do |t|
      t.integer   "p2p_offer_id",           limit: 4
      t.integer   "p2p_payment_user_id",    limit: 4
      t.string    "state",                  limit: 15, null: false
      t.datetime  "created_at"
      t.datetime  "updated_at"
    end
    add_index "p2p_order_payments", ["p2p_offer_id"], name: "index_p2p_order_payments_on_p2p_offer_id", using: :btree
    add_index "p2p_order_payments", ["p2p_payment_user_id"], name: "index_p2p_order_payments_on_p2p_payment_user_id", using: :btree

    create_table  "p2p_orders", force: :cascade do |t|
      t.integer   "p2p_user_id",              limit: 4
      t.integer   "p2p_offer_id",             limit: 4
      t.integer   "p2p_order_payment_id",     limit: 4
      t.string    "state",                    limit: 20,  default: "prepare"
      t.decimal   "amount",                               precision: 32, scale: 16
      t.string    "side",                     limit: 10,  null: false
      t.string    "aproved_by",               limit: 50,  null: true
      t.datetime  "first_approve_expire_at"
      t.datetime  "second_approve_expire_at"
      t.datetime  "created_at"
      t.datetime  "updated_at"
    end
    add_index "p2p_orders", ["p2p_user_id"], name: "index_p2p_orders_on_p2p_user_id", using: :btree
    add_index "p2p_orders", ["p2p_offer_id"], name: "index_p2p_orders_on_p2p_offer_id", using: :btree
    add_index "p2p_orders", ["p2p_order_payment_id"], name: "index_p2p_orders_on_p2p_order_payment_id", using: :btree

    create_table  "p2p_chats", force: :cascade do |t|
      t.integer   "p2p_order_id",      limit: 4
      t.integer   "p2p_user_id",       limit: 4
      t.text      "chat",              null: false
      t.datetime  "created_at"
      t.datetime  "updated_at"
    end
    add_index "p2p_chats", ["p2p_order_id"], name: "index_p2p_orders_on_p2p_order_id", using: :btree
    add_index "p2p_chats", ["p2p_user_id"], name: "index_p2p_orders_on_p2p_user_id", using: :btree

    create_table  "p2p_order_feedbacks", force: :cascade do |t|
      t.integer   "p2p_user_id",      limit: 4
      t.text      "comment",          null: false
      t.string    "assessment",       limit: 25,  null: false
      t.datetime  "created_at"
      t.datetime  "updated_at"
    end
    add_index "p2p_order_feedbacks", ["p2p_user_id"], name: "index_p2p_order_feedback_on_p2p_user_id", using: :btree

    def down
      raise ActiveRecord::IrreversibleMigration, "The initial migration is not revertable"
    end
  end
end
