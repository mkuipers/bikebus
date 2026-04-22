class LeaderClaim < ApplicationRecord
  belongs_to :ride
  belongs_to :user

  validates :claimed_at, presence: true

  scope :active, -> { where(released_at: nil) }

  def stale?
    last_ping_at.present? && last_ping_at < 3.minutes.ago
  end
end
