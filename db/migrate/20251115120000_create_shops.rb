class CreateShops < ActiveRecord::Migration[7.1]
  def change
    create_table :shops do |t|
      t.string :name, null: false
      t.integer :owner_user_id
      t.string :address
      t.string :phone
      t.string :currency, default: "PKR"
      t.string :timezone, default: "Asia/Karachi"
      t.integer :subscription_plan_id
      t.boolean :is_active, default: true

      t.timestamps
    end

    add_index :shops, :owner_user_id
    add_index :shops, :subscription_plan_id
  end
end
