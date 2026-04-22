class CreateLeaderClaims < ActiveRecord::Migration[7.2]
  def change
    create_table :leader_claims do |t|
      t.references :ride, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.datetime :claimed_at, null: false
      t.datetime :released_at
      t.datetime :last_ping_at

      t.timestamps
    end

    # only one active (unreleased) claim per ride
    add_index :leader_claims, :ride_id, unique: true,
              where: "released_at IS NULL", name: "index_leader_claims_on_ride_id_active"
  end
end
