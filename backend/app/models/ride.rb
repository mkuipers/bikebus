class Ride < ApplicationRecord
  belongs_to :route
  belongs_to :schedule, optional: true
  has_one :leader_claim, -> { where(released_at: nil) }
  has_many :all_leader_claims, class_name: "LeaderClaim"
  has_many :location_pings, dependent: :destroy
  has_many :notifications_logs, dependent: :destroy

  validates :scheduled_start_at, presence: true
  validates :status, inclusion: { in: %w[scheduled in_progress completed cancelled] }

  scope :upcoming, -> { where(status: "scheduled").where("scheduled_start_at > ?", Time.current) }
  scope :in_window, ->(hours = 2) { upcoming.where("scheduled_start_at <= ?", hours.hours.from_now) }

  def in_progress?
    status == "in_progress"
  end

  def needs_leader?
    leader_claim.nil? && scheduled_start_at <= 2.hours.from_now && status == "scheduled"
  end
end
