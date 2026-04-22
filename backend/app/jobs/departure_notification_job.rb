class DepartureNotificationJob < ApplicationJob
  queue_as :notifications

  def perform(ride_id)
    # Phase 4: send FCM push to all subscribers with notify_depart=true
  end
end
