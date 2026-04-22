class DepartureNotificationJob < ApplicationJob
  queue_as :notifications

  def perform(ride_id)
    ride = Ride.find(ride_id)

    ride.route.subscriptions.where(notify_depart: true).includes(user: :device_tokens).each do |sub|
      next if NotificationsLog.exists?(ride: ride, subscription: sub, kind: "depart")

      tokens = sub.user.device_tokens.pluck(:fcm_token)
      next if tokens.empty?

      FcmService.send_to_tokens(
        tokens,
        title: "🚲 Bike bus is rolling!",
        body:  "#{ride.route.name} has departed. Heading to #{sub.pickup_stop.name}.",
        data:  { ride_id: ride.id.to_s, kind: "depart" }
      )

      NotificationsLog.create!(ride: ride, subscription: sub, kind: "depart")
    end
  end
end
