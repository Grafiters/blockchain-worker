class AddRefferalIdOnMembers < ActiveRecord::Migration[5.2]
  def change
    add_column :members, :reff_uid, :string, limit: 75, null: true, after: :group
  end
end
