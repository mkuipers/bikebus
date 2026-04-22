require 'rails_helper'

RSpec.describe "Rides", type: :request do
  let(:user)    { create(:user) }
  let(:token)   { sign_in_as(user) }
  let(:headers) { auth_headers(token) }
  let(:route)   { create(:route) }

  describe "GET /rides" do
    let!(:ride1) { create(:ride, route: route, scheduled_start_at: 1.hour.from_now) }
    let!(:ride2) { create(:ride, route: route, scheduled_start_at: 2.hours.from_now) }
    let!(:other_ride) { create(:ride, scheduled_start_at: 3.hours.from_now) }

    it "returns all rides" do
      get "/rides", headers: headers
      expect(response).to have_http_status(:ok)
      expect(json.length).to eq(3)
    end

    it "filters by route_id" do
      get "/rides", params: { route_id: route.id }, headers: headers
      ids = json.map { |r| r["id"] }
      expect(ids).to contain_exactly(ride1.id, ride2.id)
    end

    it "filters by from/to datetime" do
      get "/rides", params: { from: 30.minutes.from_now, to: 90.minutes.from_now }, headers: headers
      expect(json.map { |r| r["id"] }).to eq([ride1.id])
    end

    it "includes needs_leader? flag" do
      get "/rides", headers: headers
      expect(json.first).to have_key("needs_leader?")
    end
  end

  describe "GET /rides/:id" do
    let!(:ride) { create(:ride, route: route) }

    it "returns the ride with route and stops" do
      get "/rides/#{ride.id}", headers: headers
      expect(response).to have_http_status(:ok)
      expect(json["id"]).to eq(ride.id)
      expect(json["route"]).to be_present
    end
  end

  describe "POST /rides/:id/claim_leader" do
    let!(:ride) { create(:ride, route: route, scheduled_start_at: 1.hour.from_now) }

    it "creates a leader claim" do
      post "/rides/#{ride.id}/claim_leader", headers: headers
      expect(response).to have_http_status(:created)
      expect(ride.reload.leader_claim).to be_present
    end

    it "rejects if an active non-stale claim exists" do
      other_user = create(:user)
      LeaderClaim.create!(ride: ride, user: other_user, claimed_at: Time.current, last_ping_at: 30.seconds.ago)
      post "/rides/#{ride.id}/claim_leader", headers: headers
      expect(response).to have_http_status(:conflict)
    end

    it "supersedes a stale claim" do
      other_user = create(:user)
      stale = LeaderClaim.create!(ride: ride, user: other_user, claimed_at: 10.minutes.ago, last_ping_at: 5.minutes.ago)
      post "/rides/#{ride.id}/claim_leader", headers: headers
      expect(response).to have_http_status(:created)
      expect(stale.reload.released_at).to be_present
    end
  end

  describe "POST /rides/:id/release_leader" do
    it "releases own claim" do
      ride = create(:ride)
      LeaderClaim.create!(ride: ride, user: user, claimed_at: Time.current)
      post "/rides/#{ride.id}/release_leader", headers: headers
      expect(response).to have_http_status(:ok)
      expect(LeaderClaim.active.where(ride: ride)).to be_empty
    end
  end

  describe "POST /rides/:id/complete" do
    it "marks ride as completed and releases leader" do
      ride = create(:ride, status: "in_progress")
      LeaderClaim.create!(ride: ride, user: user, claimed_at: Time.current)
      post "/rides/#{ride.id}/complete", headers: headers
      expect(response).to have_http_status(:ok)
      expect(ride.reload.status).to eq("completed")
      expect(LeaderClaim.active.where(ride: ride)).to be_empty
    end
  end
end
