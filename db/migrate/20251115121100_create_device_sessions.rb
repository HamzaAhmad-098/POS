class CreateDeviceSessions < ActiveRecord::Migration[7.1]
  def change
    create_table :device_sessions do |t|
      t.references :shop, foreign_key: true
      t.string :device_id
      t.datetime :last_sync_at
      t.jsonb :pending_changes_json

      t.timestamps
    end

    add_index :device_sessions, :device_id
  end
end
