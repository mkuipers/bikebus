require 'rails_helper'

RSpec.describe Subscription, type: :model do
  it { should belong_to(:user) }
  it { should belong_to(:route) }
  it { should belong_to(:pickup_stop).class_name("Stop") }

  it "prevents duplicate subscriptions for same user+route" do
    sub = create(:subscription)
    dup = build(:subscription, user: sub.user, route: sub.route)
    expect(dup).not_to be_valid
  end

  it "allows same user to subscribe to different routes" do
    user = create(:user)
    sub1 = create(:subscription, user: user)
    sub2 = build(:subscription, user: user)
    expect(sub2).to be_valid
  end
end
