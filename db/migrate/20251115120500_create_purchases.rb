class CreatePurchases < ActiveRecord::Migration[7.1]
  def change
    create_table :purchases do |t|
      t.references :shop, foreign_key: true
      t.string :vendor_name
      t.string :invoice_no
      t.integer :total_cost_cents, default: 0
      t.integer :created_by_user_id

      t.timestamps
    end
  end
end
