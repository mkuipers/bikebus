require 'rails_helper'

RSpec.describe "Routes", type: :request do
  let(:user) { create(:user) }
  let(:token) { sign_in_as(user) }
  let(:headers) { auth_headers(token) }

  describe "GET /routes" do
    let!(:public_route) { create(:route, visibility: "public") }
    let!(:private_route) { create(:route, visibility: "private") }

    it "requires authentication" do
      get "/routes"
      expect(response).to have_http_status(:unauthorized)
    end

    it "returns only public active routes by default" do
      get "/routes", headers: headers
      expect(response).to have_http_status(:ok)
      ids = json.map { |r| r["id"] }
      expect(ids).to include(public_route.id)
      expect(ids).not_to include(private_route.id)
    end

    it "filters by school name" do
      create(:route, school_name: "Lincoln Elementary", visibility: "public")
      create(:route, school_name: "Roosevelt High", visibility: "public")
      get "/routes", params: { school: "lincoln" }, headers: headers
      expect(json.map { |r| r["school_name"] }).to all(match(/Lincoln/i))
    end

    it "filters by proximity when near= is given" do
      route_with_stop = create(:route, visibility: "public")
      create(:stop, route: route_with_stop, lat: 47.6062, lng: -122.3321, position: 0)
      far_route = create(:route, visibility: "public")
      create(:stop, route: far_route, lat: 40.7128, lng: -74.0060, position: 0) # New York

      get "/routes", params: { near: "47.6062,-122.3321", radius: 1000 }, headers: headers
      ids = json.map { |r| r["id"] }
      expect(ids).to include(route_with_stop.id)
      expect(ids).not_to include(far_route.id)
    end
  end

  describe "GET /routes/:id" do
    let(:route) { create(:route) }

    it "returns the route with stops and schedules" do
      create(:stop, route: route, position: 0)
      get "/routes/#{route.id}", headers: headers
      expect(response).to have_http_status(:ok)
      expect(json["id"]).to eq(route.id)
      expect(json["stops"]).to be_an(Array)
    end

    it "returns 404 for unknown route" do
      get "/routes/999999", headers: headers
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "POST /routes" do
    let(:valid_params) do
      { route: { name: "Greenwood Bike Bus", school_name: "Greenwood Elementary", visibility: "public" } }
    end

    it "creates a route owned by current user" do
      post "/routes", params: valid_params, headers: headers, as: :json
      expect(response).to have_http_status(:created)
      expect(json["name"]).to eq("Greenwood Bike Bus")
      expect(Route.last.creator).to eq(user)
    end

    it "rejects missing required fields" do
      post "/routes", params: { route: { name: "" } }, headers: headers, as: :json
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe "PATCH /routes/:id" do
    let(:route) { create(:route, creator: user) }

    it "updates own route" do
      patch "/routes/#{route.id}", params: { route: { name: "Updated Name" } },
            headers: headers, as: :json
      expect(response).to have_http_status(:ok)
      expect(json["name"]).to eq("Updated Name")
    end

    it "cannot update another user's route" do
      other_route = create(:route)
      patch "/routes/#{other_route.id}", params: { route: { name: "Hijacked" } },
            headers: headers, as: :json
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "DELETE /routes/:id" do
    it "destroys own route" do
      route = create(:route, creator: user)
      delete "/routes/#{route.id}", headers: headers
      expect(response).to have_http_status(:no_content)
      expect(Route.find_by(id: route.id)).to be_nil
    end

    it "cannot destroy another user's route" do
      other_route = create(:route)
      delete "/routes/#{other_route.id}", headers: headers
      expect(response).to have_http_status(:not_found)
    end
  end
end
