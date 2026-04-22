require 'rails_helper'

RSpec.describe ScheduledReminderJob, type: :job do
  let(:route)  { create(:route) }
  let(:ride)   { create(:ride, route: route, status: "scheduled", scheduled_start_at: 28.minutes.from_now) }
  let(:user)   { create(:user) }
  let(:stop)   { create(:stop, route: route, position: 0) }
  let!(:sub)   { create(:subscription, user: user, route: route, pickup_stop: stop, notify_schedule: true) }
  let!(:token) { create(:device_token, user: user) }

  before { allow(FcmService).to receive(:send_to_tokens) }

  it "sends a reminder push to subscribers with notify_schedule=true" do
    described_class.new.perform(ride.id)
    expect(FcmService).to have_received(:send_to_tokens).with(
      [token.fcm_token], hash_including(title: /min/)
    )
  end

  it "creates a notifications_log entry" do
    expect { described_class.new.perform(ride.id) }
      .to change(NotificationsLog, :count).by(1)
    expect(NotificationsLog.last.kind).to eq("reminder")
  end

  it "does not send if already reminded (dedupe)" do
    NotificationsLog.create!(ride: ride, subscription: sub, kind: "reminder")
    described_class.new.perform(ride.id)
    expect(FcmService).not_to have_received(:send_to_tokens)
  end

  it "skips if ride is no longer scheduled" do
    ride.update!(status: "in_progress")
    described_class.new.perform(ride.id)
    expect(FcmService).not_to have_received(:send_to_tokens)
  end

  it "skips subscribers with notify_schedule=false" do
    sub.update!(notify_schedule: false)
    described_class.new.perform(ride.id)
    expect(FcmService).not_to have_received(:send_to_tokens)
  end
end
