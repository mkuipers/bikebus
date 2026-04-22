class CreateRoutes < ActiveRecord::Migration[7.2]
  def change
    create_table :routes do |t|
      t.references :creator, null: false, foreign_key: { to_table: :users }
      t.string :name, null: false
      t.text :description
      t.string :school_name, null: false
      t.column :path_geojson, :geometry, geographic: true  # LINESTRING
      t.string :visibility, null: false, default: "public"  # public | private | invite_only
      t.boolean :active, null: false, default: true

      t.timestamps
    end

    add_index :routes, :visibility
    add_index :routes, :active
  end
end
