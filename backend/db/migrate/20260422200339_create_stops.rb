class CreateStops < ActiveRecord::Migration[7.2]
  def change
    create_table :stops do |t|
      t.references :route, null: false, foreign_key: true
      t.integer :position, null: false
      t.string :name, null: false
      t.decimal :lat, precision: 10, scale: 7, null: false
      t.decimal :lng, precision: 10, scale: 7, null: false
      t.integer :scheduled_offset_minutes, null: false, default: 0

      t.timestamps
    end

    add_index :stops, [:route_id, :position]
  end
end
