class RideChannel < ApplicationCable::Channel
  def subscribed
    ride = Ride.find(params[:ride_id])
    stream_from "ride_#{ride.id}"
  rescue ActiveRecord::RecordNotFound
    reject
  end

  def unsubscribed; end

  # Called by the leader client every ~10 seconds with GPS data.
  def location(data)
    ride = Ride.find(params[:ride_id])
    claim = ride.leader_claim
    return unless claim&.user_id == current_user.id

    ping = LocationPing.create!(
      ride: ride,
      user: current_user,
      lat: data["lat"],
      lng: data["lng"],
      heading: data["heading"],
      speed: data["speed"],
      recorded_at: Time.current
    )

    claim.update_column(:last_ping_at, ping.recorded_at)

    if ride.status == "scheduled"
      ride.update!(status: "in_progress", started_at: ping.recorded_at)
      DepartureNotificationJob.perform_later(ride.id)
    end

    ActionCable.server.broadcast("ride_#{ride.id}", {
      type: "location",
      user_id: current_user.id,
      lat: ping.lat.to_f,
      lng: ping.lng.to_f,
      heading: ping.heading&.to_f,
      speed: ping.speed&.to_f,
      recorded_at: ping.recorded_at
    })

    ApproachNotificationJob.perform_later(ride.id, ping.id)
  end
end
