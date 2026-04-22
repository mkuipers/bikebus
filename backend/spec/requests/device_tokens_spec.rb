require 'rails_helper'

RSpec.describe "DeviceTokens", type: :request do
  let(:user)    { create(:user) }
  let(:token)   { sign_in_as(user) }
  let(:headers) { auth_headers(token) }

  describe "POST /device_tokens" do
    it "registers a new token" do
      post "/device_tokens",
        params: { fcm_token: "new_fcm_token_abc", platform: "ios" },
        headers: headers, as: :json
      expect(response).to have_http_status(:created)
      expect(user.device_tokens.count).to eq(1)
    end

    it "updates last_seen_at for an existing token" do
      existing = create(:device_token, user: user, fcm_token: "existing_token")
      post "/device_tokens",
        params: { fcm_token: "existing_token", platform: "ios" },
        headers: headers, as: :json
      expect(response).to have_http_status(:created)
      expect(user.device_tokens.count).to eq(1)
      expect(existing.reload.last_seen_at).to be_within(5.seconds).of(Time.current)
    end
  end
end
