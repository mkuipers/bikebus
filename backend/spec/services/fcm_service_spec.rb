require 'rails_helper'

RSpec.describe FcmService do
  before do
    allow(FcmService).to receive(:fresh_access_token).and_return("fake_token")
    allow(FcmService).to receive(:credentials).and_return({ "project_id" => "bikebus-test" })
  end

  describe ".send_message" do
    it "posts to the FCM v1 API with a bearer token" do
      stub = stub_request(:post, /fcm\.googleapis\.com/)
        .to_return(status: 200, body: '{"name":"projects/bikebus-46d0e/messages/123"}')

      FcmService.send_message("device_token_abc", title: "Hello", body: "World")

      expect(stub).to have_been_requested
    end

    it "includes the notification payload" do
      stub = stub_request(:post, /fcm\.googleapis\.com/)
        .with { |req| JSON.parse(req.body).dig("message", "notification", "title") == "Test" }
        .to_return(status: 200, body: "{}")

      FcmService.send_message("tok", title: "Test", body: "Body")
      expect(stub).to have_been_requested
    end

    it "logs a warning on non-200 response and does not raise" do
      stub_request(:post, /fcm\.googleapis\.com/).to_return(status: 400, body: '{"error":"invalid"}')
      expect(Rails.logger).to receive(:warn).with(/FCM/)
      expect { FcmService.send_message("tok", title: "T", body: "B") }.not_to raise_error
    end
  end

  describe ".send_to_tokens" do
    it "calls send_message for each token" do
      allow(FcmService).to receive(:send_message)
      FcmService.send_to_tokens(["tok1", "tok2"], title: "Hi", body: "There")
      expect(FcmService).to have_received(:send_message).twice
    end

    it "skips blank tokens" do
      allow(FcmService).to receive(:send_message)
      FcmService.send_to_tokens(["tok1", nil, ""], title: "Hi", body: "There")
      expect(FcmService).to have_received(:send_message).once
    end
  end
end
