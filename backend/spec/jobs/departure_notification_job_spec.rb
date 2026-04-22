require 'rails_helper'

RSpec.describe DepartureNotificationJob, type: :job do
  let(:route)  { create(:route) }
  let(:ride)   { create(:ride, route: route, status: "in_progress") }
  let(:user)   { create(:user) }
  let(:stop)   { create(:stop, route: route, position: 0) }
  let!(:sub)   { create(:subscription, user: user, route: route, pickup_stop: stop, notify_depart: true) }
  let!(:token) { create(:device_token, user: user) }

  before { allow(FcmService).to receive(:send_to_tokens) }

  it "sends a push to subscribers with notify_depart=true" do
    described_class.new.perform(ride.id)
    expect(FcmService).to have_received(:send_to_tokens).with(
      [token.fcm_token], hash_including(title: /rolling/)
    )
  end

  it "creates a notifications_log entry" do
    expect { described_class.new.perform(ride.id) }
      .to change(NotificationsLog, :count).by(1)
    expect(NotificationsLog.last.kind).to eq("depart")
  end

  it "does not send twice (dedupe)" do
    NotificationsLog.create!(ride: ride, subscription: sub, kind: "depart")
    described_class.new.perform(ride.id)
    expect(FcmService).not_to have_received(:send_to_tokens)
  end

  it "skips subscribers with notify_depart=false" do
    sub.update!(notify_depart: false)
    described_class.new.perform(ride.id)
    expect(FcmService).not_to have_received(:send_to_tokens)
  end

  it "skips users with no device tokens" do
    token.destroy!
    described_class.new.perform(ride.id)
    expect(FcmService).not_to have_received(:send_to_tokens)
  end
end
