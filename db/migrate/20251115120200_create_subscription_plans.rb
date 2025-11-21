class CreateSubscriptionPlans < ActiveRecord::Migration[7.1]
  def change
    create_table :subscription_plans do |t|
      t.string :name
      t.integer :monthly_price_pkr
      t.jsonb :features, default: {}

      t.timestamps
    end
  end
end
