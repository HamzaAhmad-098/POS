class CreateTickets < ActiveRecord::Migration[7.1]
  def change
    create_table :tickets do |t|
      t.references :shop, foreign_key: true
      t.references :user, foreign_key: true
      t.string :subject
      t.text :body
      t.string :status, default: "open"

      t.timestamps
    end
  end
end
