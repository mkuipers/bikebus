class StaleLeaderCheckJob < ApplicationJob
  queue_as :default

  def perform
    LeaderClaim.active
      .where("last_ping_at < ?", 3.minutes.ago)
      .or(LeaderClaim.active.where(last_ping_at: nil).where("claimed_at < ?", 3.minutes.ago))
      .find_each { |claim| claim.update!(released_at: Time.current) }
  end
end
