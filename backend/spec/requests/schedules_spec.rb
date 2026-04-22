require 'rails_helper'

RSpec.describe "Schedules", type: :request do
  let(:user)    { create(:user) }
  let(:token)   { sign_in_as(user) }
  let(:headers) { auth_headers(token) }
  let(:route)   { create(:route, creator: user) }

  describe "POST /routes/:route_id/schedules" do
    let(:valid_params) do
      { schedule: { start_time: "08:00", timezone: "America/Los_Angeles", days_of_week: [1, 3, 5] } }
    end

    it "creates a schedule on own route" do
      post "/routes/#{route.id}/schedules", params: valid_params, headers: headers, as: :json
      expect(response).to have_http_status(:created)
      expect(json["timezone"]).to eq("America/Los_Angeles")
      expect(json["days_of_week"]).to match_array([1, 3, 5])
    end

    it "rejects schedules on another user's route" do
      other_route = create(:route)
      post "/routes/#{other_route.id}/schedules", params: valid_params, headers: headers, as: :json
      expect(response).to have_http_status(:not_found)
    end
  end
end
