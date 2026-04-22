require 'rails_helper'

RSpec.describe "Stops", type: :request do
  let(:user)    { create(:user) }
  let(:token)   { sign_in_as(user) }
  let(:headers) { auth_headers(token) }
  let(:route)   { create(:route, creator: user) }

  describe "POST /routes/:route_id/stops" do
    let(:valid_params) { { stop: { name: "Corner of 5th & Pine", lat: 47.6062, lng: -122.3321, position: 0 } } }

    it "creates a stop on own route" do
      post "/routes/#{route.id}/stops", params: valid_params, headers: headers, as: :json
      expect(response).to have_http_status(:created)
      expect(json["name"]).to eq("Corner of 5th & Pine")
    end

    it "rejects stops on another user's route" do
      other_route = create(:route)
      post "/routes/#{other_route.id}/stops", params: valid_params, headers: headers, as: :json
      expect(response).to have_http_status(:not_found)
    end
  end
end
