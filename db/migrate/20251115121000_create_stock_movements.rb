class CreateStockMovements < ActiveRecord::Migration[7.1]
  def change
    create_table :stock_movements do |t|
      t.references :shop, foreign_key: true
      t.references :product, foreign_key: true
      t.decimal :change_qty, precision: 12, scale: 2
      t.string :reason
      t.integer :related_id
      t.string :related_type

      t.timestamps
    end

    add_index :stock_movements, [:product_id, :created_at]
  end
end
