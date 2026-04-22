class User < ApplicationRecord
  include Devise::JWT::RevocationStrategies::JTIMatcher

  devise :database_authenticatable, :registerable,
         :recoverable, :validatable,
         :jwt_authenticatable, jwt_revocation_strategy: self

  has_many :device_tokens, dependent: :destroy
  has_many :routes, foreign_key: :creator_id, dependent: :destroy
  has_many :subscriptions, dependent: :destroy
  has_many :subscribed_routes, through: :subscriptions, source: :route
  has_many :leader_claims, dependent: :destroy
  has_many :location_pings, dependent: :destroy

  validates :display_name, presence: true
end
