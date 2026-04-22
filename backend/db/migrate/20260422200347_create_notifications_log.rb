class CreateNotificationsLog < ActiveRecord::Migration[7.2]
  def change
    create_table :notifications_logs do |t|
      t.references :ride, null: false, foreign_key: true
      t.references :subscription, null: false, foreign_key: true
      t.string :kind, null: false  # "reminder" | "depart" | "approach"

      t.timestamps
    end

    add_index :notifications_logs, [:ride_id, :subscription_id, :kind], unique: true,
              name: "index_notifications_logs_dedupe"
  end
end
