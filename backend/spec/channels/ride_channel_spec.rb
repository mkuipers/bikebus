require 'rails_helper'

RSpec.describe RideChannel, type: :channel do
  let(:user) { create(:user) }
  let(:ride) { create(:ride, status: "scheduled") }

  before { stub_connection current_user: user }

  describe "#subscribed" do
    it "streams from the ride's broadcast stream" do
      subscribe(ride_id: ride.id)
      expect(subscription).to be_confirmed
      expect(subscription).to have_stream_from("ride_#{ride.id}")
    end

    it "rejects subscription for unknown ride" do
      subscribe(ride_id: 999_999)
      expect(subscription).to be_rejected
    end
  end

  describe "#location" do
    let(:claim) { LeaderClaim.create!(ride: ride, user: user, claimed_at: Time.current) }

    before do
      claim
      subscribe(ride_id: ride.id)
    end

    it "creates a LocationPing" do
      expect {
        perform(:location, "lat" => 47.6062, "lng" => -122.3321, "heading" => 270.0, "speed" => 5.5)
      }.to change(LocationPing, :count).by(1)
    end

    it "broadcasts the ping to the ride stream" do
      expect {
        perform(:location, "lat" => 47.6062, "lng" => -122.3321)
      }.to have_broadcasted_to("ride_#{ride.id}").with(hash_including("type" => "location", "lat" => 47.6062))
    end

    it "flips ride to in_progress on first ping" do
      perform(:location, "lat" => 47.6062, "lng" => -122.3321)
      expect(ride.reload.status).to eq("in_progress")
      expect(ride.started_at).to be_present
    end

    it "does not flip status again on subsequent pings" do
      ride.update!(status: "in_progress", started_at: 5.minutes.ago)
      expect {
        perform(:location, "lat" => 47.6062, "lng" => -122.3321)
      }.not_to change { ride.reload.started_at }
    end

    it "updates last_ping_at on the leader claim" do
      perform(:location, "lat" => 47.6062, "lng" => -122.3321)
      expect(claim.reload.last_ping_at).to be_within(2.seconds).of(Time.current)
    end

    it "enqueues DepartureNotificationJob on first ping" do
      expect {
        perform(:location, "lat" => 47.6062, "lng" => -122.3321)
      }.to have_enqueued_job(DepartureNotificationJob).with(ride.id)
    end

    it "enqueues ApproachNotificationJob on every ping" do
      expect {
        perform(:location, "lat" => 47.6062, "lng" => -122.3321)
      }.to have_enqueued_job(ApproachNotificationJob)
    end

    it "ignores location from a non-leader" do
      other_user = create(:user)
      stub_connection current_user: other_user
      subscribe(ride_id: ride.id)
      expect {
        perform(:location, "lat" => 47.6062, "lng" => -122.3321)
      }.not_to change(LocationPing, :count)
    end
  end
end
