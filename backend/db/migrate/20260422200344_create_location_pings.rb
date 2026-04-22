class CreateLocationPings < ActiveRecord::Migration[7.2]
  def change
    create_table :location_pings do |t|
      t.references :ride, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.decimal :lat, precision: 10, scale: 7, null: false
      t.decimal :lng, precision: 10, scale: 7, null: false
      t.decimal :heading, precision: 6, scale: 2
      t.decimal :speed, precision: 6, scale: 2
      t.datetime :recorded_at, null: false

      t.timestamps
    end

    add_index :location_pings, [:ride_id, :recorded_at]
  end
end
