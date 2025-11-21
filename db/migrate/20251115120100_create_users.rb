class CreateUsers < ActiveRecord::Migration[7.1]
  def change
    create_table :users do |t|
      t.string :full_name, null: false
      t.string :phone, null: false
      t.string :email, null: false
      t.string :password_digest, null: false
      t.integer :role, null: false
      t.references :shop, foreign_key: true, null: true
      t.datetime :last_login_at

      t.timestamps
    end

    add_index :users, :phone, unique: true
    add_index :users, :email, unique: true
  end
end
