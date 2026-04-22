class ApproachNotificationJob < ApplicationJob
  queue_as :notifications

  APPROACH_RADIUS_METRES = 400

  def perform(ride_id, ping_id)
    ride = Ride.find(ride_id)
    ping = LocationPing.find(ping_id)

    ride.route.subscriptions.where(notify_approach: true).includes(:pickup_stop, user: :device_tokens).each do |sub|
      next if NotificationsLog.exists?(ride: ride, subscription: sub, kind: "approach")

      dist = LocationPing.distance_metres(
        ping.lat.to_f, ping.lng.to_f,
        sub.pickup_stop.lat.to_f, sub.pickup_stop.lng.to_f
      )
      next if dist > APPROACH_RADIUS_METRES

      tokens = sub.user.device_tokens.pluck(:fcm_token)
      next if tokens.empty?

      FcmService.send_to_tokens(
        tokens,
        title: "📍 Bike bus approaching!",
        body:  "#{ride.route.name} is about #{dist.round(-1).to_i}m from #{sub.pickup_stop.name}.",
        data:  { ride_id: ride.id.to_s, kind: "approach" }
      )

      NotificationsLog.create!(ride: ride, subscription: sub, kind: "approach")
    end
  end
end
