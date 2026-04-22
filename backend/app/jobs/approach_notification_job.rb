class ApproachNotificationJob < ApplicationJob
  queue_as :notifications

  def perform(ride_id, ping_id)
    # Phase 4: check subscribers whose pickup stop is within ~400m of ping,
    # send FCM push if not already notified (notifications_logs dedupe)
  end
end
