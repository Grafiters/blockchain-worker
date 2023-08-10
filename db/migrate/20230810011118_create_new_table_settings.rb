class AddColumnStateOnFiat < ActiveRecord::Migration[5.2]
  def up
    create_table :settings do |t|
      t.string :name, limit: 50, null: false
      t.string :value, limit: 50, null: false
      t.text :description, null: false
      t.boolean :deleted, default: true

      t.datetime  "created_at"
      t.datetime  "updated_at"
    end

    Setting.new({
      name: 'android_version',
      value: '1.0.0',
      description: 'init version of android',
      deleted: false
    })
  end
end
