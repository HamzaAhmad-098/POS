class CreatePurchaseItems < ActiveRecord::Migration[7.1]
  def change
    create_table :purchase_items do |t|
      t.references :purchase, foreign_key: true
      t.references :product, foreign_key: true
      t.decimal :qty, precision: 12, scale: 2
      t.integer :unit_cost_cents

      t.timestamps
    end
  end
end
