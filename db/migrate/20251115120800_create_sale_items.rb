class CreateSaleItems < ActiveRecord::Migration[7.1]
  def change
    create_table :sale_items do |t|
      t.references :sale, foreign_key: true
      t.references :product, foreign_key: true
      t.decimal :qty, precision: 12, scale: 2
      t.integer :unit_price_cents
      t.integer :total_price_cents

      t.timestamps
    end
  end
end
