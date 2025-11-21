class CreateSales < ActiveRecord::Migration[7.1]
  def change
    create_table :sales do |t|
      t.references :shop, foreign_key: true
      t.references :user, foreign_key: true
      t.integer :total_cents, default: 0
      t.integer :discount_cents, default: 0
      t.integer :tax_cents, default: 0
      t.string :payment_method
      t.string :invoice_no
      t.string :status, default: "completed"
      t.integer :customer_id

      t.timestamps
    end

    add_index :sales, :invoice_no
  end
end
