class NotificationsLog < ApplicationRecord
  belongs_to :ride
  belongs_to :subscription

  validates :kind, inclusion: { in: %w[reminder depart approach] }
  validates :ride_id, uniqueness: { scope: [:subscription_id, :kind] }
end
