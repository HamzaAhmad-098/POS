class CreateCategories < ActiveRecord::Migration[7.1]
  def change
    create_table :categories do |t|
      t.references :shop, foreign_key: true
      t.string :name
      t.integer :parent_id

      t.timestamps
    end

    add_index :categories, :parent_id
  end
end
