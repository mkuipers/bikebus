class CreateDeviceTokens < ActiveRecord::Migration[7.2]
  def change
    create_table :device_tokens do |t|
      t.references :user, null: false, foreign_key: true
      t.string :fcm_token, null: false
      t.string :platform, null: false  # "ios" | "android"
      t.datetime :last_seen_at

      t.timestamps
    end

    add_index :device_tokens, :fcm_token, unique: true
  end
end
