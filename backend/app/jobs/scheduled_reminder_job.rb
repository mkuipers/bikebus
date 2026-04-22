class ScheduledReminderJob < ApplicationJob
  queue_as :notifications

  def perform(ride_id)
    ride = Ride.find(ride_id)
    return unless ride.status == "scheduled"

    ride.route.subscriptions.where(notify_schedule: true).includes(user: :device_tokens).each do |sub|
      next if NotificationsLog.exists?(ride: ride, subscription: sub, kind: "reminder")

      tokens = sub.user.device_tokens.pluck(:fcm_token)
      next if tokens.empty?

      minutes_away = ((ride.scheduled_start_at - Time.current) / 60).round
      FcmService.send_to_tokens(
        tokens,
        title: "🔔 Bike bus in ~#{minutes_away} min",
        body:  "#{ride.route.name} starts soon. Pickup at #{sub.pickup_stop.name}.",
        data:  { ride_id: ride.id.to_s, kind: "reminder" }
      )

      NotificationsLog.create!(ride: ride, subscription: sub, kind: "reminder")
    end
  end
end
