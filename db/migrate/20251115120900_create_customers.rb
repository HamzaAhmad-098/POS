class CreateCustomers < ActiveRecord::Migration[7.1]
  def change
    create_table :customers do |t|
      t.references :shop, foreign_key: true
      t.string :name
      t.string :phone
      t.integer :credit_balance_cents, default: 0

      t.timestamps
    end

    add_index :customers, :phone
  end
end
