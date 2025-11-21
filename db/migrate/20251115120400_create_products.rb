class CreateProducts < ActiveRecord::Migration[7.1]
  def change
    create_table :products do |t|
      t.references :shop, foreign_key: true
      t.string :sku
      t.string :barcode
      t.string :name
      t.references :category, foreign_key: true, null: true
      t.string :brand
      t.string :unit
      t.integer :purchase_price_cents, default: 0, null: false
      t.integer :selling_price_cents, default: 0, null: false
      t.decimal :current_stock, default: 0, precision: 12, scale: 2, null: false
      t.decimal :reorder_level, default: 0, precision: 12, scale: 2
      t.date :expiry_date

      t.timestamps
    end
    add_index :products, :barcode
    add_index :products, :sku
  end
end
