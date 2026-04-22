class Subscription < ApplicationRecord
  belongs_to :user
  belongs_to :route
  belongs_to :pickup_stop, class_name: "Stop"

  validates :user_id, uniqueness: { scope: :route_id }
end
