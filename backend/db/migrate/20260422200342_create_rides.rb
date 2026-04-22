class CreateRides < ActiveRecord::Migration[7.2]
  def change
    create_table :rides do |t|
      t.references :route, null: false, foreign_key: true
      t.references :schedule, null: true, foreign_key: true
      t.datetime :scheduled_start_at, null: false
      t.string :status, null: false, default: "scheduled"  # scheduled | in_progress | completed | cancelled
      t.datetime :started_at
      t.datetime :ended_at

      t.timestamps
    end

    add_index :rides, [:route_id, :scheduled_start_at]
    add_index :rides, :status
  end
end
