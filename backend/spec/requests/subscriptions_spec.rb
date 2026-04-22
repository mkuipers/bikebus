require 'rails_helper'

RSpec.describe "Subscriptions", type: :request do
  let(:user)    { create(:user) }
  let(:token)   { sign_in_as(user) }
  let(:headers) { auth_headers(token) }

  describe "GET /subscriptions" do
    it "returns user's subscriptions" do
      create(:subscription, user: user)
      create(:subscription) # another user's subscription
      get "/subscriptions", headers: headers
      expect(response).to have_http_status(:ok)
      expect(json.length).to eq(1)
    end
  end

  describe "POST /subscriptions" do
    let(:route) { create(:route) }
    let(:stop)  { create(:stop, route: route, position: 0) }

    it "creates a subscription" do
      post "/subscriptions",
        params: { subscription: { route_id: route.id, pickup_stop_id: stop.id } },
        headers: headers, as: :json
      expect(response).to have_http_status(:created)
      expect(user.subscriptions.count).to eq(1)
    end

    it "rejects duplicate subscription" do
      create(:subscription, user: user, route: route, pickup_stop: stop)
      post "/subscriptions",
        params: { subscription: { route_id: route.id, pickup_stop_id: stop.id } },
        headers: headers, as: :json
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe "DELETE /subscriptions/:id" do
    it "destroys own subscription" do
      sub = create(:subscription, user: user)
      delete "/subscriptions/#{sub.id}", headers: headers
      expect(response).to have_http_status(:no_content)
    end

    it "cannot destroy another user's subscription" do
      other_sub = create(:subscription)
      delete "/subscriptions/#{other_sub.id}", headers: headers
      expect(response).to have_http_status(:not_found)
    end
  end
end
