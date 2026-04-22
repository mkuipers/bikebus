class CreateSchedules < ActiveRecord::Migration[7.2]
  def change
    create_table :schedules do |t|
      t.references :route, null: false, foreign_key: true
      t.integer :days_of_week, array: true, null: false, default: []  # 0=Sun..6=Sat
      t.time :start_time, null: false
      t.string :timezone, null: false, default: "UTC"
      t.boolean :active, null: false, default: true

      t.timestamps
    end
  end
end
