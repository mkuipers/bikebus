require 'rails_helper'

RSpec.describe ApproachNotificationJob, type: :job do
  let(:route)  { create(:route) }
  let(:ride)   { create(:ride, route: route, status: "in_progress") }
  let(:user)   { create(:user) }
  # Stop near Seattle center
  let(:stop)   { create(:stop, route: route, position: 0, lat: 47.6062, lng: -122.3321) }
  let!(:sub)   { create(:subscription, user: user, route: route, pickup_stop: stop, notify_approach: true) }
  let!(:token) { create(:device_token, user: user) }

  before { allow(FcmService).to receive(:send_to_tokens) }

  def make_ping(lat:, lng:)
    LocationPing.create!(ride: ride, user: user, lat: lat, lng: lng, recorded_at: Time.current)
  end

  it "sends a push when ping is within 400m of subscriber's stop" do
    ping = make_ping(lat: 47.6065, lng: -122.3325) # ~40m away
    described_class.new.perform(ride.id, ping.id)
    expect(FcmService).to have_received(:send_to_tokens).with(
      [token.fcm_token], hash_including(title: /approaching/)
    )
  end

  it "does not send when ping is farther than 400m" do
    ping = make_ping(lat: 47.650, lng: -122.400) # ~5km away
    described_class.new.perform(ride.id, ping.id)
    expect(FcmService).not_to have_received(:send_to_tokens)
  end

  it "creates a notifications_log entry on send" do
    ping = make_ping(lat: 47.6065, lng: -122.3325)
    expect { described_class.new.perform(ride.id, ping.id) }
      .to change(NotificationsLog, :count).by(1)
  end

  it "does not send twice (dedupe)" do
    ping = make_ping(lat: 47.6065, lng: -122.3325)
    NotificationsLog.create!(ride: ride, subscription: sub, kind: "approach")
    described_class.new.perform(ride.id, ping.id)
    expect(FcmService).not_to have_received(:send_to_tokens)
  end
end
