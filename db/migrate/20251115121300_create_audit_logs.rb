class CreateAuditLogs < ActiveRecord::Migration[7.1]
  def change
    create_table :audit_logs do |t|
      t.integer :actor_user_id
      t.string :action
      t.string :auditable_type
      t.integer :auditable_id
      t.jsonb :changes_json

      t.timestamps
    end

    add_index :audit_logs, :actor_user_id
  end
end
