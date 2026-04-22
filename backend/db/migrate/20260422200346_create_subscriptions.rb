class CreateSubscriptions < ActiveRecord::Migration[7.2]
  def change
    create_table :subscriptions do |t|
      t.references :user, null: false, foreign_key: true
      t.references :route, null: false, foreign_key: true
      t.references :pickup_stop, null: false, foreign_key: { to_table: :stops }
      t.boolean :notify_schedule, null: false, default: true
      t.boolean :notify_depart, null: false, default: true
      t.boolean :notify_approach, null: false, default: true

      t.timestamps
    end

    add_index :subscriptions, [:user_id, :route_id], unique: true
  end
end
