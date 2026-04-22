require 'rails_helper'

RSpec.describe "Auth", type: :request do
  describe "POST /auth/sign_up" do
    let(:valid_params) do
      { user: { email: "new@example.com", password: "password123",
                password_confirmation: "password123", display_name: "New User" } }
    end

    it "creates a user and returns a JWT" do
      post "/auth/sign_up", params: valid_params, as: :json
      expect(response).to have_http_status(:created)
      expect(response.headers["Authorization"]).to be_present
      expect(json["user"]["email"]).to eq("new@example.com")
    end

    it "returns errors with invalid params" do
      post "/auth/sign_up", params: { user: { email: "", password: "x" } }, as: :json
      expect(response).to have_http_status(:unprocessable_entity)
      expect(json["errors"]).to be_present
    end

    it "rejects duplicate email" do
      create(:user, email: "taken@example.com")
      post "/auth/sign_up",
        params: { user: { email: "taken@example.com", password: "password123",
                          password_confirmation: "password123", display_name: "Dup" } },
        as: :json
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe "POST /auth/sign_in" do
    let!(:user) { create(:user, email: "rider@example.com", password: "password123") }

    it "returns a JWT on valid credentials" do
      post "/auth/sign_in",
        params: { user: { email: "rider@example.com", password: "password123" } },
        as: :json
      expect(response).to have_http_status(:ok)
      expect(response.headers["Authorization"]).to match(/^Bearer /)
      expect(json["user"]["email"]).to eq("rider@example.com")
    end

    it "rejects invalid credentials" do
      post "/auth/sign_in",
        params: { user: { email: "rider@example.com", password: "wrongpass" } },
        as: :json
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe "DELETE /auth/sign_out" do
    let!(:user) { create(:user) }
    let(:token) { sign_in_as(user) }

    it "signs out and revokes the token" do
      delete "/auth/sign_out", headers: auth_headers(token)
      expect(response).to have_http_status(:ok)

      # revoked token should no longer work
      get "/routes", headers: auth_headers(token)
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe "JWT protection" do
    it "rejects requests without a token" do
      get "/routes"
      expect(response).to have_http_status(:unauthorized)
    end

    it "rejects requests with a malformed token" do
      get "/routes", headers: { "Authorization" => "Bearer not-a-real-token" }
      expect(response).to have_http_status(:unauthorized)
    end

    it "accepts requests with a valid token" do
      user = create(:user)
      token = sign_in_as(user)
      get "/routes", headers: auth_headers(token)
      expect(response).to have_http_status(:ok)
    end
  end
end
