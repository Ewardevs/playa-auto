class CreateAuditLogs < ActiveRecord::Migration[8.1]
  def change
    create_table :audit_logs do |t|
      # Nullable so the trail survives deleting the user who wrote it, and so
      # system-generated entries can be recorded.
      t.references :user, null: true, foreign_key: { on_delete: :nullify }
      # Denormalised: the log must stay readable after the actor is gone.
      t.string :user_name

      t.references :auditable, polymorphic: true, null: true, index: false
      t.string :auditable_label

      t.string :action, null: false
      # { "price" => [32000.0, 30500.0], "status" => ["available", "reserved"] }
      t.jsonb  :changed_data, null: false, default: {}

      t.datetime :created_at, null: false
    end

    add_index :audit_logs, [ :auditable_type, :auditable_id, :created_at ],
              name: "index_audit_logs_on_auditable_and_created_at"
    add_index :audit_logs, :created_at
    add_index :audit_logs, :action
  end
end
